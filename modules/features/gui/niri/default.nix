{ self, ... }:
{
  perSystem =
    { lib, pkgs, ... }:
    {
      packages = lib.optionalAttrs pkgs.stdenv.isLinux {
        niri = (import ./_modules/compositor.nix { inherit self lib pkgs; }).programs.niri.package;
      };
    };

  flake.nixosModules.gui-niri = {
    imports = [ ./_modules/compositor.nix ];
  };
}
