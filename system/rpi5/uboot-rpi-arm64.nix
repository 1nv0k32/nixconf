{ pkgs, lib, ... }:
let
  fetchLorePatch =
    {
      name,
      msgId,
      hash,
    }:
    pkgs.fetchurl {
      inherit name hash;
      url = "https://lore.kernel.org/u-boot/${msgId}@verein.lst.de/raw";
      curlOptsList = [
        "-A"
        "git/2.40"
      ];
    };
  rpi5-nvme-patches = [
    (fetchLorePatch {
      name = "0001-core-skip-parent-nodes-without-dt.patch";
      msgId = "20260706172147.C934268B05";
      hash = "sha256-Yp/3vVmrVNa4Y5Z4/W4KEu6c7+clIKNiAf92BTsanVA=";
    })
    (fetchLorePatch {
      name = "0003-nvme-translate-pcie-inbound-addresses.patch";
      msgId = "20260706172152.5257168BFE";
      hash = "sha256-QcnJ9/LYM3+IiYk3v1vI3eIulyVaCEouwYJzUE5PrCQ=";
    })
    (fetchLorePatch {
      name = "0004-rpi-enable-nvme.patch";
      msgId = "20260706172154.B506B68CFE";
      hash = "sha256-G6Tp0yGK+rBztOzFe6iMKjo1IjULSGXhNkz5OrHNnPk=";
    })
  ];
in
{
  hardware.raspberry-pi.firmware.uboot.package =
    lib.mkForce
      (pkgs.unstable.ubootRaspberryPiAarch64.override {
        extraPatches = rpi5-nvme-patches;
      }).overrideAttrs
      (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace board/raspberrypi/rpi/rpi.env \
            --replace-fail "boot_targets=mmc usb pxe dhcp" \
            "boot_targets=nvme mmc usb pxe dhcp"
        '';
      });
}
