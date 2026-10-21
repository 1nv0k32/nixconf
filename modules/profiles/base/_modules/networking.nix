{ lib, ... }:
{
  imports = [
    ./networkd.nix
    ./dns.nix
  ];

  networking = {
    wireless.iwd.enable = true;
    networkmanager = {
      wifi.backend = "iwd";
      dns = "systemd-resolved";
      settings = {
        main = {
          no-auto-default = "*";
          systemd-resolved = true;
        };
      };
    };
    firewall = {
      enable = lib.mkDefault true;
      checkReversePath = true;
      allowPing = false;
    };
  };
}
