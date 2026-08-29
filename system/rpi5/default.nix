{
  self,
  lib,
  ...
}:
{
  imports = [
    (import ./disko.nix)
    (import ./uboot-rpi-arm64.nix)
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
      uboot = {
        enable = true;
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
    kernelParams = [
      "cgroup_enable=cpuset"
      "cgroup_enable=memory"
      "cgroup_memory=1"
      "8250.nr_uarts=1"
      "rootflags=data=journal"
    ];
  };
}
