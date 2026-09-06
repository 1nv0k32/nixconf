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
                  'CONFIG_PREBOOT="pci enum; nvme scan; sysboot nvme 0:2 any ''${scriptaddr} /boot/extlinux/extlinux.conf;"'
                echo 'CONFIG_CONSOLE_RECORD=y' >> configs/rpi_arm64_defconfig
                echo 'CONFIG_CONSOLE_RECORD_OUT_SIZE=0x80000' >> configs/rpi_arm64_defconfig
                echo 'CONFIG_FAT_WRITE=y' >> configs/rpi_arm64_defconfig
                substituteInPlace cmd/sysboot.c \
                  --replace-fail $'#include <pxe_utils.h>\n#include <vsprintf.h>' \
                  $'#include <console.h>\n#include <pxe_utils.h>\n#include <vsprintf.h>\n#include <linux/string.h>' \
                  --replace-fail $'\tint ret;\n\n\tif (argc > 1 && strstr(argv[1], "-p")) {' \
                  $'\tint ret;\n\n\tconsole_record_reset_enable();\n\tif (argc > 1 && strstr(argv[1], "-p")) {' \
                  --replace-fail $'\tpxe_destroy_ctx(&ctx);\n\tif (ret)' \
                  $'\tpxe_destroy_ctx(&ctx);\n\t{\n\t\tstatic char _log[0x80000];\n\t\tint _len = 0, _r;\n\t\tchar _line[256];\n\t\twhile (_len < (int)sizeof(_log) - 258) {\n\t\t\t_r = console_record_readline(_line, sizeof(_line));\n\t\t\tif (_r < 0)\n\t\t\t\tbreak;\n\t\t\tmemcpy(_log + _len, _line, _r);\n\t\t\t_len += _r;\n\t\t\t_log[_len++] = 0x0a;\n\t\t}\n\t\tif (_len > 0 && !fs_set_blk_dev("nvme", "0:1", FS_TYPE_ANY)) {\n\t\t\tloff_t _w;\n\t\t\tfs_write("uboot-log.txt", (ulong)_log, 0, _len, &_w);\n\t\t}\n\t}\n\tif (ret)'
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
