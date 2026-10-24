import importlib.util
import subprocess
import unittest
from pathlib import Path
from unittest.mock import patch


path = Path(__file__).resolve().parents[1] / "assets" / "brightness.py"
spec = importlib.util.spec_from_file_location("brightness", path)
brightness = importlib.util.module_from_spec(spec)
spec.loader.exec_module(brightness)


class BrightnessTests(unittest.TestCase):
    def test_external_and_builtin_displays(self):
        with patch.object(
            brightness,
            "run",
            return_value=(
                "ddcci19,backlight,40,40%,100\n"
                "ddcci20,backlight,128,50%,255\n"
                "panel,backlight,500,50%,1000"
            ),
        ):
            displays = brightness.read_displays()
        self.assertEqual([d.percent for d in displays], [40, 50, 50])
        self.assertEqual(brightness.status(displays)["text"], "40% / 50% / 50%")

    def test_invalid_backlights_do_not_hide_builtin(self):
        with patch.object(
            brightness,
            "run",
            return_value=(
                "invalid,backlight,0,0%,0\n"
                "led,leds,1,100%,1\n"
                "panel,backlight,30,30%,100"
            ),
        ):
            displays = brightness.read_displays()
        self.assertEqual(len(displays), 1)
        self.assertEqual(displays[0].label, "Built-in display (panel)")

    def test_uses_native_logind_brightness_api(self):
        with patch.object(
            brightness, "run", return_value="ddcci19,backlight,40,40%,100"
        ):
            display = brightness.read_displays()[0]
        self.assertEqual(display.command[0], "busctl")
        self.assertIn("SetBrightness", display.command)
        self.assertEqual(display.command[-2:], ("backlight", "ddcci19"))

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
            brightness.Display("External", 40, 100, ("busctl", "ddcci19")),
            brightness.Display("Built-in", 500, 1000, ("busctl", "panel")),
        ]
        with patch.object(brightness, "run", side_effect=[None, ""]) as run:
            self.assertFalse(brightness.adjust(displays, 5))
        self.assertEqual(run.call_args_list[0].args[-1], "45")
        self.assertEqual(run.call_args_list[1].args[-1], "550")

    def test_command_timeout_is_nonfatal(self):
        with patch.object(
            brightness.subprocess,
            "run",
            side_effect=subprocess.TimeoutExpired("brightnessctl", 10),
        ):
            self.assertIsNone(brightness.run("brightnessctl", "--list"))


if __name__ == "__main__":
    unittest.main()
