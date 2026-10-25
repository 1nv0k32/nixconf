{ lib, pkgs, ... }:
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
    programs.winbox = {
      enable = true;
      openFirewall = true;
    };
  };
}
