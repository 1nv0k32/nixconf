import argparse
import fcntl
import json
import os
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
    backlight = run(
        "brightnessctl", "--class=backlight", "--machine-readable", "--list"
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
                    (
                        f"External monitor ({fields[0]})"
                        if fields[0].startswith("ddcci")
                        else f"Built-in display ({fields[0]})"
                    ),
                    int(fields[2]),
                    int(fields[4]),
                    (
                        "busctl",
                        "call",
                        "org.freedesktop.login1",
                        "/org/freedesktop/login1/session/auto",
                        "org.freedesktop.login1.Session",
                        "SetBrightness",
                        "ssu",
                        "backlight",
                        fields[0],
                    ),
                )
            )
    return displays


def status(displays):
    if not displays:
        return {
            "text": "—",
            "tooltip": "No backlights found. External monitors need the DDC backlight driver.",
            "class": "unavailable",
        }
    return {
        "text": " / ".join(f"{display.percent}%" for display in displays),
        "tooltip": "\n".join(
            [f"{display.label}: {display.percent}%" for display in displays]
            + ["Scroll/click: brighter · Scroll down/right-click: dimmer"]
        ),
    }


def notify(displays):
    if not displays:
        return
    percent = round(sum(display.percent for display in displays) / len(displays))
    label = " / ".join(dict.fromkeys(f"{display.percent}%" for display in displays))
    run(
        "notify-send",
        "--category=osd",
        "--transient",
        "--hint=string:x-canonical-private-synchronous:osd",
        f"--hint=int:value:{max(0, min(100, percent))}",
        f"󰃠  Brightness  {label}",
    )


def adjust(displays, delta):
    results = []
    for display in displays:
        target = display.target(delta)
        ok = run(*display.command, str(target)) is not None
        if ok:
            display.current = target
        results.append(ok)
    if any(results):
        notify(displays)
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
