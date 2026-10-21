{
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
    programs.winbox = {
      enable = true;
      openFirewall = true;
      package = pkgs.winbox;
    };
  };
}
