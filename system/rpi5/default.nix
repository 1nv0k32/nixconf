{
  self,
  pkgs,
  lib,
  ...
}:
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
  imports = [
    (import ./disko.nix)
    # (import "${self}/modules/etc/media.nix")
    # (import "${self}/modules/etc/gitea.nix")
  ];

  users.users.root.initialPassword = "root";

  hardware.raspberry-pi = {
    configtxt.settings.all.dtparam = lib.mkAfter [
      "usb_max_current_enable=1"
      "pciex1=on"
      "pciex1_gen=3"
    ];
    firmware = {
      enable = true;
      package = pkgs.unstable.raspberrypifw;
      uboot = {
        enable = true;
        package =
          (pkgs.unstable.ubootRaspberryPiAarch64.override {
            extraPatches = rpi5-nvme-patches;
          }).overrideAttrs
            (old: {
              postPatch = (old.postPatch or "") + ''
                substituteInPlace board/raspberrypi/rpi/rpi.env \
                  --replace-fail "boot_targets=mmc usb pxe dhcp" \
                  "boot_targets=nvme mmc pxe dhcp"
                substituteInPlace configs/rpi_arm64_defconfig \
                  --replace-fail 'CONFIG_PREBOOT="pci enum; usb start; nvme scan;"' \
                  'CONFIG_PREBOOT="pci enum; nvme scan; if load nvme 0:2 ''${scriptaddr} /boot/extlinux/extlinux.conf; then sleep 3; reset; fi;"'
              '';
            });
      };
    };
  };

  networking = {
    useDHCP = lib.mkForce false;
    firewall.enable = lib.mkForce false;
  };

  systemd = {
    network.enable = true;
    tpm2.enable = lib.mkForce false;
  };

  boot = {
    initrd.systemd.tpm2.enable = lib.mkForce false;
    kernel.sysctl."vm.mmap_rnd_bits" = lib.mkForce null;
    kernelParams = [
      "cgroup_enable=cpuset"
      "cgroup_enable=memory"
      "cgroup_memory=1"
      "8250.nr_uarts=1"
      "console=tty0"
    ];
  };
}
