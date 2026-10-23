{ lib, ... }:
{
  imports = [
    ./networkd.nix
    ./dns.nix
  ];

  networking = {
    wireless.iwd.enable = true;
    firewall = {
      enable = lib.mkDefault true;
      checkReversePath = true;
      allowPing = false;
    };
  };
}
