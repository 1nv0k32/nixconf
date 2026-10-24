import argparse
import json
import subprocess


def parse_labels(pairs):
    return dict(pair.split("=", 1) for pair in pairs)


def short_label(name, labels):
    return labels.get(name) or name[:2].upper()


def apply(event, state):
    """Updates state from a niri IPC event; returns True if the layout display may have changed."""
    if "KeyboardLayoutsChanged" in event:
        layouts = event["KeyboardLayoutsChanged"]["keyboard_layouts"]
        state["names"] = layouts["names"]
        state["index"] = layouts["current_idx"]
        return True
    if "KeyboardLayoutSwitched" in event:
        state["index"] = event["KeyboardLayoutSwitched"]["idx"]
        return True
    return False


def status(state, labels):
    names, index = state.get("names", []), state.get("index", -1)
    if not 0 <= index < len(names):
        return None
    name = names[index]
    label = short_label(name, labels)
    return {
        "text": label,
        "tooltip": f"Keyboard layout: {name}\nClick or Super+Space to switch",
        "class": label.lower(),
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--niri", required=True)
    parser.add_argument("--label", action="append", default=[], metavar="NAME=TEXT")
    args = parser.parse_args()
    labels = parse_labels(args.label)

    state = {}
    with subprocess.Popen(
        [args.niri, "msg", "--json", "event-stream"], stdout=subprocess.PIPE, text=True
    ) as stream:
        for line in stream.stdout:
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            if apply(event, state) and (document := status(state, labels)):
                try:
                    print(json.dumps(document), flush=True)
                except BrokenPipeError:
                    stream.terminate()
                    return 0
    # The stream only ends when niri goes away; Waybar restarts the module.
    return stream.returncode or 1


if __name__ == "__main__":
    raise SystemExit(main())
