{ self, ... }:
{
  perSystem =
    { lib, pkgs, ... }:
    {
      packages = lib.optionalAttrs pkgs.stdenv.isLinux {
        niri = (import ./compositor.nix { inherit self lib pkgs; }).programs.niri.package;
      };
    };

  flake.nixosModules.gui-niri = {
    imports = [
      ./compositor.nix
      ./session.nix
    ];
  };
}
