{
  self,
  lib,
  pkgs,
  niriShell,
  ...
}:
let
  shell = niriShell;
  empty = _: { };
in
{
  programs.niri = {
    enable = true;
    package = self.inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      prefixVar = [
        [
          "XCURSOR_PATH"
          ":"
          "${pkgs.adwaita-icon-theme}/share/icons"
        ]
      ];
      settings = {
        prefer-no-csd = empty;
        hotkey-overlay.skip-at-startup = empty;
        cursor = {
          xcursor-theme = "Adwaita";
          xcursor-size = 24;
        };
        input = {
          keyboard = {
            xkb = {
              layout = "us,ir";
              options = "grp:alt_shift_toggle";
            };
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

        binds = import ./binds.nix { inherit lib pkgs shell; };

        layout = {
          gaps = 10;
          background-color = shell.colors.base;
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
            active-color = shell.colors.accent;
            inactive-color = shell.colors.surface;
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
        ];

        workspaces = lib.genAttrs shell.workspaces (_: { });

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
      };
    };
  };

  environment.systemPackages = [
    shell.launcher
    shell.sessionMenu
    shell.lock
    shell.volume
    shell.brightness
    pkgs.playerctl
    pkgs.brightnessctl
    pkgs.adwaita-icon-theme
    pkgs.papirus-icon-theme
  ];
}
