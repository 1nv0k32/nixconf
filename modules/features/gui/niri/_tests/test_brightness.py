import importlib.util
import subprocess
import unittest
from pathlib import Path
from unittest.mock import patch


path = Path(__file__).resolve().parents[1] / "_assets" / "brightness.py"
spec = importlib.util.spec_from_file_location("brightness", path)
brightness = importlib.util.module_from_spec(spec)
spec.loader.exec_module(brightness)


class BrightnessTests(unittest.TestCase):
    def test_external_and_builtin_displays(self):
        with patch.object(
            brightness,
            "run",
            side_effect=[
                "Invalid display\nDisplay 1\nDisplay 2\n",
                "VCP 10 C 40 100",
                "VCP 10 C 128 255",
                "panel,backlight,500,50%,1000",
            ],
        ):
            displays = brightness.read_displays()
        self.assertEqual([d.percent for d in displays], [40, 50, 50])
        self.assertEqual(brightness.status(displays)["text"], "40% / 50% / 50%")

    def test_unsupported_external_does_not_hide_builtin(self):
        with patch.object(
            brightness,
            "run",
            side_effect=[
                "Display 1\n",
                None,
                "panel,backlight,30,30%,100",
            ],
        ):
            displays = brightness.read_displays()
        self.assertEqual(len(displays), 1)
        self.assertEqual(displays[0].label, "Built-in display")

    def test_no_displays(self):
        with patch.object(brightness, "run", return_value=None):
            displays = brightness.read_displays()
        self.assertEqual(brightness.status(displays)["class"], "unavailable")
        self.assertFalse(brightness.adjust(displays, 5))

    def test_limits_and_non_percentage_brightness_ranges(self):
        display = brightness.Display("Test", 1, 100, ())
        self.assertEqual(display.target(-5), 1)
        display.current = 99
        self.assertEqual(display.target(5), 100)
        display = brightness.Display("Test", 500, 1000, ())
        self.assertEqual(display.target(5), 550)
        self.assertEqual(display.target(-5), 450)

    def test_adjusts_every_display_even_after_failure(self):
        displays = [
            brightness.Display("External", 40, 100, ("ddcutil", "setvcp", "10")),
            brightness.Display("Built-in", 500, 1000, ("brightnessctl", "set")),
        ]
        with patch.object(brightness, "run", side_effect=[None, ""]) as run:
            self.assertFalse(brightness.adjust(displays, 5))
        self.assertEqual(run.call_args_list[0].args[-1], "45")
        self.assertEqual(run.call_args_list[1].args[-1], "550")

    def test_command_timeout_is_nonfatal(self):
        with patch.object(
            brightness.subprocess,
            "run",
            side_effect=subprocess.TimeoutExpired("ddcutil", 10),
        ):
            self.assertIsNone(brightness.run("ddcutil", "detect"))


if __name__ == "__main__":
    unittest.main()
