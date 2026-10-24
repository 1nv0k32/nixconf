{
  self,
  lib,
  pkgs,
  ...
}:
let
  empty = _: { };
  shell = import ./shell.nix { inherit self lib pkgs; };
  niriPackage = self.inputs.wrapper-modules.wrappers.niri.wrap {
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
      environment = {
        GTK_IM_MODULE = null;
        QT_IM_MODULE = null;
        XMODIFIERS = null;
      };
      cursor = {
        xcursor-theme = "Adwaita";
        xcursor-size = 24;
      };
      input = {
        focus-follows-mouse = _: {
          props.max-scroll-amount = "0%";
        };
        keyboard = {
          xkb = {
            layout = "us,ir";
            options = "grp:win_space_toggle";
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
        mouse = {
          accel-profile = "flat";
        };
      };

      binds = {
        "Mod+Return".spawn = lib.getExe pkgs.kitty;
        "Mod+Q".close-window = empty;
        "Mod+S".spawn = lib.getExe shell.launcher;
        "Mod+E".spawn = lib.getExe pkgs.nautilus;
        "Mod+Tab".toggle-overview = empty;
        "Mod+Shift+Tab".switch-focus-between-floating-and-tiling = empty;
        "Mod+Shift+Slash".show-hotkey-overlay = empty;
        "Mod+Escape".spawn = lib.getExe shell.sessionMenu;
        "Mod+Ctrl+Escape".spawn = lib.getExe shell.lock;

        "Mod+F".maximize-column = empty;
        "Mod+G".fullscreen-window = empty;
        "Mod+Shift+F".toggle-window-floating = empty;
        "Mod+C".center-column = empty;
        "Mod+R".switch-preset-column-width = empty;
        "Mod+Shift+R".reset-window-height = empty;
        "Mod+W".toggle-column-tabbed-display = empty;
        "Mod+BracketLeft".consume-or-expel-window-left = empty;
        "Mod+BracketRight".consume-or-expel-window-right = empty;

        # Vim directions: left, down, up, right.
        "Mod+H".focus-column-left = empty;
        "Mod+J".focus-window-down = empty;
        "Mod+K".focus-window-up = empty;
        "Mod+L".focus-column-right = empty;

        # Shift moves the focused window or column in the same direction.
        "Mod+Shift+H".move-column-left = empty;
        "Mod+Shift+J".move-window-down = empty;
        "Mod+Shift+K".move-window-up = empty;
        "Mod+Shift+L".move-column-right = empty;

        # Vim paging: U/D changes workspace; Shift sends the column.
        "Mod+U".focus-workspace-up = empty;
        "Mod+D".focus-workspace-down = empty;
        "Mod+Shift+U".move-column-to-workspace-up = empty;
        "Mod+Shift+D".move-column-to-workspace-down = empty;

        # Previous/next monitor; Shift sends the column.
        "Mod+Ctrl+P".focus-monitor-previous = empty;
        "Mod+Ctrl+N".focus-monitor-next = empty;
        "Mod+Ctrl+Shift+P".move-column-to-monitor-previous = empty;
        "Mod+Ctrl+Shift+N".move-column-to-monitor-next = empty;

        "Mod+1".focus-workspace = "w0";
        "Mod+2".focus-workspace = "w1";
        "Mod+3".focus-workspace = "w2";
        "Mod+4".focus-workspace = "w3";
        "Mod+5".focus-workspace = "w4";

        "Mod+Shift+1".move-column-to-workspace = "w0";
        "Mod+Shift+2".move-column-to-workspace = "w1";
        "Mod+Shift+3".move-column-to-workspace = "w2";
        "Mod+Shift+4".move-column-to-workspace = "w3";
        "Mod+Shift+5".move-column-to-workspace = "w4";

        # Ctrl resizes: grow right/down, shrink left/up.
        "Mod+Ctrl+H".set-column-width = "-5%";
        "Mod+Ctrl+J".set-window-height = "+5%";
        "Mod+Ctrl+K".set-window-height = "-5%";
        "Mod+Ctrl+L".set-column-width = "+5%";

        # Native screenshots support selection and copy directly to the clipboard.
        "Print".screenshot = empty;
        "Mod+Print".screenshot-screen = empty;
        "Mod+Shift+Print".screenshot-window = empty;
        "Mod+Shift+S".spawn = lib.getExe shell.suspend;

        # Audio & Media (dconf.nix + XF86Audio* keys)
        "Mod+V".spawn = [
          (lib.getExe shell.volume)
          "mic-mute"
        ];
        "XF86AudioMicMute".spawn = [
          (lib.getExe shell.volume)
          "mic-mute"
        ];
        "Mod+F12".spawn = [
          (lib.getExe shell.volume)
          "up"
        ];
        "Mod+F11".spawn = [
          (lib.getExe shell.volume)
          "down"
        ];
        "Mod+F10".spawn = [
          (lib.getExe shell.volume)
          "mute"
        ];
        "XF86AudioRaiseVolume".spawn = [
          (lib.getExe shell.volume)
          "up"
        ];
        "XF86AudioLowerVolume".spawn = [
          (lib.getExe shell.volume)
          "down"
        ];
        "XF86AudioMute".spawn = [
          (lib.getExe shell.volume)
          "mute"
        ];
        "XF86MonBrightnessUp".spawn = [
          (lib.getExe shell.brightness)
          "up"
        ];
        "XF86MonBrightnessDown".spawn = [
          (lib.getExe shell.brightness)
          "down"
        ];

        "Mod+Ctrl+Right".spawn-sh = "${lib.getExe pkgs.playerctl} next";
        "Mod+Ctrl+Down".spawn-sh = "${lib.getExe pkgs.playerctl} play-pause";
        "Mod+Ctrl+Left".spawn-sh = "${lib.getExe pkgs.playerctl} previous";
        "Mod+Ctrl+Up".spawn-sh = "${lib.getExe pkgs.playerctl} stop";
        "XF86AudioNext".spawn-sh = "${lib.getExe pkgs.playerctl} next";
        "XF86AudioPlay".spawn-sh = "${lib.getExe pkgs.playerctl} play-pause";
        "XF86AudioPrev".spawn-sh = "${lib.getExe pkgs.playerctl} previous";
        "XF86AudioStop".spawn-sh = "${lib.getExe pkgs.playerctl} stop";
      };

      layout = {
        gaps = 10;
        background-color = shell.colors.background;
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
            { app-id = "^(kitty|net\\.kovidgoyal\\.kitty)$"; }
            { app-id = "^(chromium|chromium-browser|org\\.chromium\\.Chromium)$"; }
          ];
          open-floating = false;
          open-maximized = false;
          open-fullscreen = false;
          default-column-width.proportion = 0.5;
        }
        {
          matches = [
            { app-id = "^(org\\.pulseaudio\\.pavucontrol|com\\.saivert\\.pwvucontrol)$"; }
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

      workspaces = lib.genAttrs (map (i: "w${toString i}") (lib.range 0 4)) (_: { });

      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

      spawn-at-startup = [
        (lib.getExe shell.waybar)
        (lib.getExe shell.notifications)
        (lib.getExe shell.idle)
        [
          (lib.getExe pkgs.swaybg)
          "-i"
          "${../assets/backgroud-image.jpg}"
          "-m"
          "center"
        ]
      ];
    };
  };
in
{
  programs.niri = {
    enable = true;
    package = niriPackage;
  };

  programs.dconf.enable = lib.mkDefault true;
  services.upower.enable = true;

  environment.systemPackages = with pkgs; [
    shell.launcher
    shell.waybar
    shell.sessionMenu
    shell.lock
    shell.volume
    shell.brightness
    swaybg
    playerctl
    brightnessctl
    xwayland-satellite
    adwaita-icon-theme
    papirus-icon-theme
  ];
}
