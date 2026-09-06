{
  self,
  pkgs,
  lib,
  config,
  ...
}:
let
  # Reuse the exact kernel command line NixOS generates, so U-Boot's bootargs
  # never drift from config.boot.kernelParams. init points at the current
  # system profile so it stays valid across generations.
  ubootBootargs = lib.concatStringsSep " " (
    [ "init=/nix/var/nix/profiles/system/init" ] ++ config.boot.kernelParams
  );
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
    (import "${self}/modules/etc/media.nix")
    (import "${self}/modules/etc/gitea.nix")
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
                  'CONFIG_PREBOOT="pci enum; nvme scan; load nvme 0:2 ''${kernel_addr_r} /nix/var/nix/profiles/system/kernel; load nvme 0:2 ''${ramdisk_addr_r} /nix/var/nix/profiles/system/initrd; setenv ramdisk_size ''${filesize}; setenv bootargs ${ubootBootargs}; booti ''${kernel_addr_r} ''${ramdisk_addr_r}:''${ramdisk_size} ''${fdt_addr};"'
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
    loader.generic-extlinux-compatible.configurationLimit = 3;
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
