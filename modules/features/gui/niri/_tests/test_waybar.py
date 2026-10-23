import importlib.util
import tempfile
import unittest
from pathlib import Path


path = Path(__file__).resolve().parents[1] / "_assets" / "waybar.py"
spec = importlib.util.spec_from_file_location("native_waybar", path)
waybar = importlib.util.module_from_spec(spec)
spec.loader.exec_module(waybar)


class WaybarTests(unittest.TestCase):
    def setUp(self):
        self.template = {
            "modules-right": ["network", "group/audio", "group/brightness", "battery"],
            "group/brightness": {"modules": ["custom/brightness"]},
        }

    def test_native_sliders_target_each_detected_backlight(self):
        config = waybar.configuration(self.template, ["amdgpu_bl1", "ddcci19"])
        self.assertEqual(
            config["group/brightness"]["modules"],
            [
                "custom/brightness",
                "backlight#amdgpu_bl1",
                "backlight/slider#amdgpu_bl1",
                "backlight#ddcci19",
                "backlight/slider#ddcci19",
            ],
        )
        self.assertEqual(config["backlight/slider#ddcci19"]["device"], "ddcci19")
        self.assertEqual(config["backlight/slider#ddcci19"]["min"], 1)
        self.assertEqual(config["backlight/slider#amdgpu_bl1"]["max"], 100)
        self.assertIn("External", config["backlight#ddcci19"]["tooltip-format"])

    def test_no_backlight_means_no_empty_clickable_drawer(self):
        config = waybar.configuration(self.template, [])
        self.assertNotIn("group/brightness", config["modules-right"])

    def test_reconnection_uses_new_name_without_stale_controls(self):
        waybar.configuration(self.template, ["ddcci19"])
        config = waybar.configuration(self.template, ["ddcci21"])
        self.assertNotIn("backlight/slider#ddcci19", config)
        self.assertEqual(config["backlight/slider#ddcci21"]["device"], "ddcci21")
        self.assertEqual(
            self.template["group/brightness"]["modules"], ["custom/brightness"]
        )

    def test_discovers_only_usable_backlights(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, maximum in [
                ("ddcci19", "100"),
                ("amdgpu_bl1", "65535"),
                ("invalid", "0"),
                ("malformed", "invalid"),
            ]:
                device = root / name
                device.mkdir()
                (device / "max_brightness").write_text(maximum)
                (device / "brightness").write_text("1")
            self.assertEqual(waybar.backlights(root), ["amdgpu_bl1", "ddcci19"])

    def test_missing_backlight_directory(self):
        with tempfile.TemporaryDirectory() as directory:
            self.assertEqual(waybar.backlights(Path(directory) / "missing"), [])


if __name__ == "__main__":
    unittest.main()
