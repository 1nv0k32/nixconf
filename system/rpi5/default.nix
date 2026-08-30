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
      "pciex1_gen=3"
    ];
    firmware = {
      enable = true;
      package = pkgs.unstable.raspberrypifw;
      uboot = {
        enable = true;
        package =
          (pkgs.unstable.ubootRaspberryPiAarch64.override {
            extraConfig = ''
              # --- 1. DISABLE INCOMPATIBLE PI 4 DRIVER ---
              CONFIG_VIDEO_BCM2835=n

              # --- 2. PIGGYBACK ON PI 5 FIRMWARE FRAMEBUFFER ---
              CONFIG_VIDEO_SIMPLE=y

              # --- 3. ENABLE VIDEO & CONSOLE MULTIPLEXING ---
              CONFIG_VIDEO=y
              CONFIG_DM_VIDEO=y
              CONFIG_CONSOLE_MUX=y
              CONFIG_SYS_CONSOLE_IS_IN_ENV=y

              # --- 4. PREVENT LOGOS FROM HIDING TEXT ---
              CONFIG_VIDEO_LOGO=n
              CONFIG_SPLASH_SCREEN=n
              CONFIG_CONSOLE_SCROLLING=y

              # --- 5. VERBOSE LOGGING ---
              CONFIG_LOG=y
              CONFIG_LOGLEVEL=7
              CONFIG_SPL_LOG=n
            '';
            extraPatches = rpi5-nvme-patches;
          }).overrideAttrs
            (old: {
              postPatch = (old.postPatch or "") + ''
                substituteInPlace board/raspberrypi/rpi/rpi.env \
                  --replace-fail "boot_targets=mmc usb pxe dhcp" \
                  "boot_targets=nvme mmc usb pxe dhcp"

                sed -i 's/"stdout=serial\\0"/"stdout=serial,vidconsole\\0"/g' include/env_default.h
                sed -i 's/"stderr=serial\\0"/"stderr=serial,vidconsole\\0"/g' include/env_default.h
                find include/configs/ -type f -exec sed -i 's/stdout=serial/stdout=serial,vidconsole/g' {} +
                find include/configs/ -type f -exec sed -i 's/stderr=serial/stderr=serial,vidconsole/g' {} +
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
      "rootflags=data=journal"
    ];
  };
}
