import logging
import re
from pathlib import Path


def read_edid(number):
    from smbus2 import SMBus, i2c_msg

    with SMBus(number) as bus:
        offset = i2c_msg.write(0x50, [0])
        data = i2c_msg.read(0x50, 128)
        bus.i2c_rdwr(offset, data)
        return bytes(data)


def external_buses(drm=Path("/sys/class/drm"), devices=Path("/sys/bus/i2c/devices")):
    buses = set()
    mst_edids = set()
    for connector in drm.glob("card*-*"):
        if re.search(r"-(eDP|LVDS|DSI)-", connector.name):
            continue
        try:
            if (connector / "status").read_text().strip() != "connected":
                continue
            ddc = connector / "ddc"
            adapter = re.fullmatch(r"i2c-(\d+)", ddc.resolve().name)
            if ddc.exists() and adapter:
                buses.add(int(adapter.group(1)))
            else:
                edid = (connector / "edid").read_bytes()
                if len(edid) >= 128:
                    mst_edids.add(edid[:128])
        except OSError:
            continue

    # MST connectors lack a ddc symlink. Match their EDIDs without touching
    # address 0x37, which is owned by the ddcci kernel driver.
    if mst_edids:
        for adapter in devices.glob("i2c-*"):
            match = re.fullmatch(r"i2c-(\d+)", adapter.name)
            if not match:
                continue
            try:
                if (adapter / "name").read_text().strip() != "DPMST":
                    continue
                number = int(match.group(1))
                if read_edid(number) in mst_edids:
                    buses.add(number)
            except OSError:
                continue
    return buses


def bind_backlights(
    buses,
    devices=Path("/sys/bus/i2c/devices"),
    driver=Path("/sys/bus/i2c/drivers/ddcci"),
):
    for client in devices.glob("*-0037"):
        match = re.fullmatch(r"(\d+)-0037", client.name)
        if not match or int(match.group(1)) in buses:
            continue
        try:
            if (client / "name").read_text().strip() == "ddcci":
                bus = devices / f"i2c-{match.group(1)}"
                (bus / "delete_device").write_text("0x37\n")
        except OSError as error:
            logging.warning("Cannot remove disconnected %s: %s", client.name, error)

    for number in sorted(buses):
        client = devices / f"{number}-0037"
        try:
            if client.exists():
                if (client / "name").read_text().strip() != "ddcci":
                    continue
                if not (client / "driver").exists():
                    (driver / "bind").write_text(f"{client.name}\n")
            else:
                bus = devices / f"i2c-{number}"
                (bus / "new_device").write_text("ddcci 0x37\n")
        except OSError as error:
            logging.warning(
                "Cannot register DDC backlight on i2c-%s: %s", number, error
            )


def main():
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    bind_backlights(external_buses())


if __name__ == "__main__":
    main()
