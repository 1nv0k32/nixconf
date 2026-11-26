{ lib, pkgs, ... }:
let
  systemctl = "${pkgs.systemd}/bin/systemctl";
  # Laptop panels are recognised by connector type, so the profiles work on any machine.
  internal = "n/^(eDP|LVDS|DSI)-";
  # Only the laptop panel is on when nothing else is connected; otherwise only the
  # external displays are.
  profile = externals: {
    name = if externals == 0 then "laptop" else "external";
    output = [
      {
        search = internal;
        enable = externals == 0;
      }
    ]
    ++ lib.replicate externals {
      search = "n/.*";
      enable = true;
    };
  };
in
{
  # niri has no "external only" mode; shikane switches outputs through wlr-output-management
  # when displays are plugged in. Mod+P (wdisplays) changes them by hand until the next hotplug.
  # A profile from `shikanectl export` (searching by vendor/model/serial) ranks above these
  # generic ones, which is how to pin a layout for a specific desk.
  home-manager.sharedModules = [
    (
      { lib, ... }:
      {
        services.shikane = {
          enable = true;
          settings.profile = map profile [
            0
            1
            2
            3
          ];
        };

        # shikane reads its config only at start, and a unit added mid-session is not started.
        xdg.configFile."shikane/config.toml".onChange =
          "${systemctl} --user try-restart shikane.service || true";
        home.activation.startShikane = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
          if ${systemctl} --user -q is-active graphical-session.target 2>/dev/null; then
            run ${systemctl} --user start shikane.service
          fi
        '';
      }
    )
  ];
}
