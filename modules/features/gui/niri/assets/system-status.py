import argparse
import json
import os
import time
from pathlib import Path

GIB = 2**30


def cpu_times(stat):
    """Returns (total, idle) jiffies from the aggregate line of /proc/stat."""
    fields = [int(value) for value in stat.splitlines()[0].split()[1:]]
    idle = fields[3] + (fields[4] if len(fields) > 4 else 0)
    return sum(fields), idle


def cpu_percent(previous, current):
    total = current[0] - previous[0]
    idle = current[1] - previous[1]
    return 0 if total <= 0 else round(100 * (total - idle) / total)


def memory(meminfo):
    """Returns (used, total) bytes, counting reclaimable cache as available."""
    values = {}
    for line in meminfo.splitlines():
        key, _, rest = line.partition(":")
        values[key] = int(rest.split()[0]) * 1024
    total = values["MemTotal"]
    return total - values["MemAvailable"], total


def disk(stat):
    """Returns (used, free) bytes the way df reports them for unprivileged users."""
    used = (stat.f_blocks - stat.f_bfree) * stat.f_frsize
    return used, stat.f_bavail * stat.f_frsize


def percent(part, whole):
    return 0 if whole <= 0 else round(100 * part / whole)


def status(cpu, ram, ssd):
    ram_used, ram_total = ram
    ssd_used, ssd_free = ssd
    return {
        "text": f"{cpu}%",
        "tooltip": "\n".join(
            [
                f"CPU {cpu}%",
                f"RAM {ram_used / GIB:.1f} / {ram_total / GIB:.1f} GiB ({percent(ram_used, ram_total)}%)",
                f"SSD {ssd_free / GIB:.0f} GiB free ({percent(ssd_used, ssd_used + ssd_free)}% used)",
                "Click for details",
            ]
        ),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--interval", type=float, default=5)
    parser.add_argument("--path", default="/")
    args = parser.parse_args()

    stat, meminfo = Path("/proc/stat"), Path("/proc/meminfo")
    previous = cpu_times(stat.read_text())
    # A short first sample gets a tooltip on screen without waiting a full interval.
    delay = 0.5
    while True:
        time.sleep(delay)
        delay = args.interval
        current = cpu_times(stat.read_text())
        document = status(
            cpu_percent(previous, current),
            memory(meminfo.read_text()),
            disk(os.statvfs(args.path)),
        )
        previous = current
        try:
            print(json.dumps(document), flush=True)
        except BrokenPipeError:
            return 0


if __name__ == "__main__":
    raise SystemExit(main())
