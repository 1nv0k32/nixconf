{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  theme = import ../theme.nix { inherit pkgs; };
  workspaces = map (i: "w${toString i}") (lib.range 0 4);
  empty = _: { };
in
{
  programs.niri = {
    enable = true;
    package = self.inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        prefer-no-csd = empty;
        hotkey-overlay.skip-at-startup = empty;
        cursor = {
          xcursor-theme = theme.cursor.theme;
          xcursor-size = theme.cursor.size;
        };
        input = {
          keyboard = {
            inherit (theme) xkb;
            track-layout = "window";
            repeat-rate = 40;
            repeat-delay = 600;
          };
          touchpad = {
            tap = empty;
            dwt = empty;
            natural-scroll = empty;
            click-method = "button-areas";
            middle-emulation = empty;
          };
          mouse.accel-profile = "flat";
        };

        binds = import ./binds.nix {
          inherit lib pkgs workspaces;
          noctalia = lib.getExe config.programs.noctalia.package;
        };

        layout = {
          gaps = 10;
          background-color = theme.background;
          center-focused-column = "on-overflow";
          always-center-single-column = empty;
          default-column-width.proportion = 0.5;
          preset-column-widths = [
            { proportion = 0.333333; }
            { proportion = 0.5; }
            { proportion = 0.666667; }
          ];
          focus-ring = {
            width = 2;
            active-color = theme.palette.accent;
            inactive-color = theme.palette.outline;
          };
          border.off = empty;
          shadow = {
            on = empty;
            softness = 20;
            spread = 2;
            offset = _: {
              props = {
                x = 0;
                y = 4;
              };
            };
            color = "#00000040";
          };
        };

        window-rules = [
          {
            geometry-corner-radius = 12;
            clip-to-geometry = true;
          }
          {
            matches = [
              { app-id = "^com\\.saivert\\.pwvucontrol$"; }
              { app-id = "^nm-connection-editor$"; }
              { app-id = "^org\\.gnome\\.Calculator$"; }
              { app-id = "^floating\\."; }
            ];
            open-floating = true;
          }
          {
            matches = [
              {
                app-id = "^org\\.gnome\\.Nautilus$";
                title = "^(Properties|.* Properties)$";
              }
            ];
            open-floating = true;
          }
          {
            matches = [ { app-id = "^dev\\.noctalia\\.Noctalia$"; } ];
            open-floating = true;
            default-column-width.fixed = 1080;
            default-window-height.fixed = 920;
          }
        ];

        workspaces = lib.genAttrs workspaces (_: { });

        overview.backdrop-color = "#404040";

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        # Lets Noctalia's notification actions and launcher activate windows.
        debug.honor-xdg-activation-with-invalid-serial = empty;
      };
    };
  };

  # The cursor theme is found through XCURSOR_PATH, which includes the system profile.
  environment.systemPackages = [ theme.cursor.package ];
}
