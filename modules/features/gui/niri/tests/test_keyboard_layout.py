import importlib.util
import unittest
from pathlib import Path


path = Path(__file__).resolve().parents[1] / "assets" / "keyboard-layout.py"
spec = importlib.util.spec_from_file_location("keyboard_layout", path)
keyboard_layout = importlib.util.module_from_spec(spec)
spec.loader.exec_module(keyboard_layout)

LABELS = {"English (US)": "EN", "Persian": "FA"}
CHANGED = {
    "KeyboardLayoutsChanged": {
        "keyboard_layouts": {"names": ["English (US)", "Persian"], "current_idx": 0}
    }
}


class KeyboardLayoutTests(unittest.TestCase):
    def test_parse_labels_keeps_equals_in_text(self):
        self.assertEqual(
            keyboard_layout.parse_labels(["English (US)=EN", "A=B=C"]),
            {"English (US)": "EN", "A": "B=C"},
        )

    def test_unknown_layout_falls_back_to_its_name(self):
        self.assertEqual(keyboard_layout.short_label("German", LABELS), "GE")

    def test_layouts_then_switch(self):
        state = {}
        self.assertTrue(keyboard_layout.apply(CHANGED, state))
        self.assertEqual(
            keyboard_layout.status(state, LABELS),
            {
                "text": "EN",
                "tooltip": "Keyboard layout: English (US)\nClick or Shift+Alt to switch",
                "class": "en",
            },
        )
        self.assertTrue(keyboard_layout.apply({"KeyboardLayoutSwitched": {"idx": 1}}, state))
        self.assertEqual(keyboard_layout.status(state, LABELS)["text"], "FA")

    def test_unrelated_events_are_ignored(self):
        state = {}
        self.assertFalse(keyboard_layout.apply({"WorkspaceActivated": {"id": 1}}, state))
        self.assertIsNone(keyboard_layout.status(state, LABELS))

    def test_switch_before_layouts_is_not_shown(self):
        state = {}
        keyboard_layout.apply({"KeyboardLayoutSwitched": {"idx": 1}}, state)
        self.assertIsNone(keyboard_layout.status(state, LABELS))


if __name__ == "__main__":
    unittest.main()
