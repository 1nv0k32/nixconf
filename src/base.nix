{
  self,
  hostName,
  domain,
  lib,
  ...
}:
{
  imports = [
    (import ./users.nix)
    (import ./lib/systemd.nix)
    (import ./lib/logind.nix)
    (import ./lib/networking.nix)
    (import ./lib/console.nix)
  ];

  boot = {
    tmp.cleanOnBoot = true;
    blacklistedKernelModules = [ "snd_pcsp" ];
  };

  networking = {
    hostName = hostName;
    domain = domain;
  };

  hardware = {
    enableAllFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    wirelessRegulatoryDatabase = true;
  };

  time = {
    timeZone = "CET";
    hardwareClockInLocalTime = false;
  };

  environment = {
    etc = {
      "nixos/flake.nix" = {
        source = "${self}/flakes/flake.nix";
        mode = "0444";
      };
    };
    variables = {
      LIBVIRT_DEFAULT_URI = lib.mkForce "qemu:///system";
    };
  };
}
