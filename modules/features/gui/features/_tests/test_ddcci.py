import importlib.util
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import MagicMock, Mock, patch


path = Path(__file__).resolve().parents[1] / "_assets" / "ddcci.py"
spec = importlib.util.spec_from_file_location("ddcci", path)
ddcci = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ddcci)


class DiscoveryTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        root = Path(self.temporary.name)
        self.drm = root / "drm"
        self.devices = root / "devices"
        self.drm.mkdir()
        self.devices.mkdir()
        self.edid = bytes(range(128))

    def adapter(self, number, name="DPMST"):
        adapter = self.devices / f"i2c-{number}"
        adapter.mkdir()
        (adapter / "name").write_text(name)
        return adapter

    def connector(self, name, *, status="connected", edid=None):
        connector = self.drm / name
        connector.mkdir()
        (connector / "status").write_text(status)
        (connector / "edid").write_bytes(self.edid if edid is None else edid)
        return connector

    def discover(self):
        return ddcci.external_buses(self.drm, self.devices)

    def test_mst_monitor_without_sysfs_ddc_link_is_discovered(self):
        self.adapter(19)
        self.connector("card1-DP-9")
        with patch.object(ddcci, "read_edid", return_value=self.edid) as read:
            self.assertEqual(self.discover(), {19})
            read.assert_called_once_with(19)

    def test_direct_ddc_link_does_not_need_i2c_discovery(self):
        adapter = self.adapter(7, "AMDGPU DM aux hw bus 0")
        connector = self.connector("card1-HDMI-A-1")
        (connector / "ddc").symlink_to(adapter)
        with patch.object(ddcci, "read_edid") as read:
            self.assertEqual(self.discover(), {7})
            read.assert_not_called()

    def test_multiple_mst_monitors(self):
        self.adapter(19)
        self.adapter(21)
        self.connector("card1-DP-9")
        second_edid = bytes(reversed(range(128)))
        self.connector("card1-DP-10", edid=second_edid)
        with patch.object(ddcci, "read_edid", side_effect=[self.edid, second_edid]):
            self.assertEqual(self.discover(), {19, 21})

    def test_internal_and_disconnected_panels_are_not_probed(self):
        self.adapter(19)
        for name in ("card1-eDP-1", "card1-LVDS-1", "card1-DSI-1"):
            self.connector(name)
        self.connector("card1-DP-9", status="disconnected")
        with patch.object(ddcci, "read_edid") as read:
            self.assertEqual(self.discover(), set())
            read.assert_not_called()

    def test_unrelated_smbus_is_not_probed(self):
        self.adapter(0, "SMBus adapter")
        self.connector("card1-DP-9")
        with patch.object(ddcci, "read_edid") as read:
            self.assertEqual(self.discover(), set())
            read.assert_not_called()

    def test_different_monitor_edid_is_not_matched(self):
        self.adapter(19)
        self.connector("card1-DP-9")
        with patch.object(ddcci, "read_edid", return_value=b"invalid"):
            self.assertEqual(self.discover(), set())

    def test_unplugged_mst_adapter_is_ignored(self):
        self.adapter(19)
        self.connector("card1-DP-9")
        with patch.object(ddcci, "read_edid", side_effect=OSError("disconnected")):
            self.assertEqual(self.discover(), set())

    def test_edid_read_uses_only_address_0x50(self):
        data = bytearray(self.edid)
        module = SimpleNamespace(
            SMBus=MagicMock(),
            i2c_msg=SimpleNamespace(
                write=Mock(return_value="offset"), read=Mock(return_value=data)
            ),
        )
        with patch.dict("sys.modules", {"smbus2": module}):
            self.assertEqual(ddcci.read_edid(19), self.edid)
        module.i2c_msg.write.assert_called_once_with(0x50, [0])
        module.i2c_msg.read.assert_called_once_with(0x50, 128)
        bus = module.SMBus.return_value.__enter__.return_value
        bus.i2c_rdwr.assert_called_once_with("offset", data)

    def test_failed_discovery_does_not_remove_existing_devices(self):
        with (
            patch.object(ddcci, "external_buses", side_effect=OSError("unavailable")),
            patch.object(ddcci, "bind_backlights") as bind,
        ):
            with self.assertRaises(OSError):
                ddcci.main()
            bind.assert_not_called()


class BindingTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        root = Path(self.temporary.name)
        self.devices = root / "devices"
        self.driver = root / "driver"
        self.devices.mkdir()
        self.driver.mkdir()
        (self.driver / "bind").write_text("unchanged")

    def adapter(self, number):
        adapter = self.devices / f"i2c-{number}"
        adapter.mkdir()
        (adapter / "new_device").write_text("unchanged")
        (adapter / "delete_device").write_text("unchanged")
        return adapter

    def client(self, number, *, name="ddcci", bound=False):
        client = self.devices / f"{number}-0037"
        client.mkdir()
        (client / "name").write_text(f"{name}\n")
        if bound:
            (client / "driver").mkdir()
        return client

    def sync(self, buses):
        ddcci.bind_backlights(buses, self.devices, self.driver)

    def test_registers_ddc_on_selected_adapter_only(self):
        internal = self.adapter(3)
        external = self.adapter(19)
        self.sync({19})
        self.assertEqual((external / "new_device").read_text(), "ddcci 0x37\n")
        self.assertEqual((internal / "new_device").read_text(), "unchanged")

    def test_already_bound_monitor_is_not_registered_twice(self):
        adapter = self.adapter(19)
        self.client(19, bound=True)
        self.sync({19})
        self.assertEqual((adapter / "new_device").read_text(), "unchanged")
        self.assertEqual((self.driver / "bind").read_text(), "unchanged")

    def test_retries_binding_after_a_failed_probe(self):
        adapter = self.adapter(19)
        self.client(19)
        self.sync({19})
        self.assertEqual((self.driver / "bind").read_text(), "19-0037\n")
        self.assertEqual((adapter / "new_device").read_text(), "unchanged")

    def test_leaves_another_i2c_driver_alone(self):
        adapter = self.adapter(19)
        self.client(19, name="another-driver")
        self.sync({19})
        self.sync(set())
        self.assertEqual((adapter / "new_device").read_text(), "unchanged")
        self.assertEqual((adapter / "delete_device").read_text(), "unchanged")
        self.assertEqual((self.driver / "bind").read_text(), "unchanged")

    def test_removes_disconnected_backlight(self):
        adapter = self.adapter(19)
        self.client(19, bound=True)
        self.sync(set())
        self.assertEqual((adapter / "delete_device").read_text(), "0x37\n")

    def test_hot_unplug_during_probe_does_not_block_other_monitor(self):
        adapter = self.adapter(21)
        with self.assertLogs(level="WARNING"):
            self.sync({19, 21})
        self.assertEqual((adapter / "new_device").read_text(), "ddcci 0x37\n")


if __name__ == "__main__":
    unittest.main()
