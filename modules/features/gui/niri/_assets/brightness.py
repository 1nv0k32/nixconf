import argparse
import fcntl
import json
import os
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path


@dataclass
class Display:
    label: str
    current: int
    maximum: int
    command: tuple

    @property
    def percent(self):
        return round(100 * self.current / self.maximum)

    def target(self, delta):
        step = max(1, round(self.maximum * abs(delta) / 100))
        minimum = max(1, (self.maximum + 99) // 100)
        value = self.current + (step if delta > 0 else -step)
        return min(self.maximum, max(minimum, value))


def run(*command):
    try:
        return subprocess.run(
            command, check=True, capture_output=True, text=True, timeout=10
        ).stdout.strip()
    except (OSError, subprocess.SubprocessError):
        return None


def read_displays():
    displays = []
    detected = run("ddcutil", "detect", "--brief") or ""
    for number in re.findall(r"^Display (\d+)\s*$", detected, re.MULTILINE):
        value = run("ddcutil", "--display", number, "--brief", "getvcp", "10")
        match = re.fullmatch(r"VCP 10 C (\d+) (\d+)", value or "")
        if match and int(match[2]) > 0:
            displays.append(
                Display(
                    f"External {number} (DDC)",
                    int(match[1]),
                    int(match[2]),
                    ("ddcutil", "--display", number, "setvcp", "10"),
                )
            )

    backlight = run(
        "brightnessctl", "--class=backlight", "--machine-readable", "info"
    )
    for line in (backlight or "").splitlines():
        fields = line.split(",")
        if (
            len(fields) == 5
            and fields[1] == "backlight"
            and fields[2].isdigit()
            and fields[4].isdigit()
            and int(fields[4]) > 0
        ):
            displays.append(
                Display(
                    "Built-in display",
                    int(fields[2]),
                    int(fields[4]),
                    ("brightnessctl", "--device", fields[0], "set"),
                )
            )
    return displays


def status(displays):
    if not displays:
        return {
            "text": "—",
            "tooltip": "No brightness controls found. Enable DDC/CI on external monitors.",
            "class": "unavailable",
        }
    return {
        "text": " / ".join(f"{display.percent}%" for display in displays),
        "tooltip": "\n".join(
            [f"{display.label}: {display.percent}%" for display in displays]
            + ["Scroll/click: brighter · Scroll down/right-click: dimmer"]
        ),
    }


def adjust(displays, delta):
    results = [
        run(*display.command, str(display.target(delta))) is not None
        for display in displays
    ]
    return bool(results) and all(results)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "action", nargs="?", choices=("status", "up", "down"), default="status"
    )
    args = parser.parse_args()
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if not runtime:
        parser.error("XDG_RUNTIME_DIR is required")
    with (Path(runtime) / "niri-brightness.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        displays = read_displays()
        if args.action == "status":
            print(json.dumps(status(displays)))
            return 0
        return 0 if adjust(displays, 5 if args.action == "up" else -5) else 1


if __name__ == "__main__":
    raise SystemExit(main())
