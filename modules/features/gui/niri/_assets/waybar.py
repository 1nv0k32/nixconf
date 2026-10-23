import argparse
import copy
import json
import os
import signal
import subprocess
import tempfile
import threading
from pathlib import Path


def backlights(root=Path("/sys/class/backlight")):
    devices = []
    if not root.is_dir():
        return devices
    for device in root.iterdir():
        try:
            maximum = int((device / "max_brightness").read_text())
            if maximum > 0 and (device / "brightness").exists():
                devices.append(device.name)
        except (OSError, ValueError):
            continue
    return sorted(devices)


def configuration(template, devices):
    config = copy.deepcopy(template)
    if not devices:
        config["modules-right"].remove("group/brightness")
        return config

    modules = config["group/brightness"]["modules"]
    for device in devices:
        label = f"backlight#{device}"
        slider = f"backlight/slider#{device}"
        external = device.startswith("ddcci")
        kind = "External monitor" if external else "Built-in display"
        icon = "󰍹" if external else "󰌢"
        modules.extend([label, slider])
        config[label] = {
            "device": device,
            "format": f"{icon} {{percent}}%",
            "tooltip-format": f"{kind} ({device}): {{percent}}%",
            "interval": 5,
            "scroll-step": 5.0,
            "min-brightness": 1.0,
        }
        config[slider] = {
            "device": device,
            "min": 1,
            "max": 100,
            "orientation": "horizontal",
            "interval": 3000,
        }
    return config


def main():
    import pyudev

    parser = argparse.ArgumentParser()
    parser.add_argument("--template", type=Path, required=True)
    parser.add_argument("--binary", required=True)
    parser.add_argument("--style", required=True)
    args, extra = parser.parse_known_args()
    template = json.loads(args.template.read_text())
    monitor = pyudev.Monitor.from_netlink(pyudev.Context())
    monitor.filter_by("backlight")
    monitor.start()

    with tempfile.TemporaryDirectory(
        prefix="niri-waybar-", dir=os.environ.get("XDG_RUNTIME_DIR")
    ) as runtime:
        path = Path(runtime) / "config.json"
        lock = threading.Lock()

        def write_config():
            temporary = path.with_suffix(".tmp")
            temporary.write_text(json.dumps(configuration(template, backlights())))
            temporary.replace(path)

        write_config()
        child = subprocess.Popen(
            [args.binary, "--config", str(path), "--style", args.style, *extra]
        )

        def reload_backlights(device):
            if device.action not in ("add", "remove"):
                return
            with lock:
                write_config()
                if child.poll() is None:
                    child.send_signal(signal.SIGUSR2)

        def forward(signum, _frame):
            if child.poll() is None:
                child.send_signal(signum)

        for signum in (signal.SIGTERM, signal.SIGINT, signal.SIGUSR1, signal.SIGUSR2):
            signal.signal(signum, forward)
        observer = pyudev.MonitorObserver(monitor, callback=reload_backlights)
        observer.start()
        try:
            result = child.wait()
        finally:
            observer.stop()
        return result if result >= 0 else 128 - result


if __name__ == "__main__":
    raise SystemExit(main())
