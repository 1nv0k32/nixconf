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

    # GNOME supplies IBus globally; Niri uses the configured XKB layouts.
    systemd.user.services."app-ibus\\x2ddaemon@autostart" = {
      overrideStrategy = "asDropin";
      unitConfig.ConditionEnvironment = "!XDG_CURRENT_DESKTOP=niri";
    };
  };
}
