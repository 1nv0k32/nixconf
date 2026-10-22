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
    settings = {
      prefer-no-csd = empty;
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
          repeat-delay = 250;
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
        "Mod+Alt+L".spawn = lib.getExe shell.lock;

        "Mod+F".maximize-column = empty;
        "Mod+G".fullscreen-window = empty;
        "Mod+Shift+F".toggle-window-floating = empty;
        "Mod+C".center-column = empty;
        "Mod+R".switch-preset-column-width = empty;
        "Mod+Shift+R".reset-window-height = empty;
        "Mod+W".toggle-column-tabbed-display = empty;
        "Mod+BracketLeft".consume-or-expel-window-left = empty;
        "Mod+BracketRight".consume-or-expel-window-right = empty;

        "Mod+H".focus-column-left = empty;
        "Mod+L".focus-column-right = empty;
        "Mod+K".focus-window-up = empty;
        "Mod+J".focus-window-down = empty;

        "Mod+Left".focus-column-left = empty;
        "Mod+Right".focus-column-right = empty;
        "Mod+Up".focus-window-up = empty;
        "Mod+Down".focus-window-down = empty;

        "Mod+Shift+H".move-column-left = empty;
        "Mod+Shift+L".move-column-right = empty;
        "Mod+Shift+K".move-window-up = empty;
        "Mod+Shift+J".move-window-down = empty;

        "Mod+Shift+Left".move-column-left = empty;
        "Mod+Shift+Right".move-column-right = empty;
        "Mod+Shift+Up".move-window-up = empty;
        "Mod+Shift+Down".move-window-down = empty;

        "Mod+Page_Up".focus-workspace-up = empty;
        "Mod+Page_Down".focus-workspace-down = empty;
        "Mod+Shift+Page_Up".move-column-to-workspace-up = empty;
        "Mod+Shift+Page_Down".move-column-to-workspace-down = empty;
        "Mod+Alt+Left".focus-monitor-left = empty;
        "Mod+Alt+Right".focus-monitor-right = empty;
        "Mod+Shift+Alt+Left".move-column-to-monitor-left = empty;
        "Mod+Shift+Alt+Right".move-column-to-monitor-right = empty;

        "Mod+1".focus-workspace = "w0";
        "Mod+2".focus-workspace = "w1";
        "Mod+3".focus-workspace = "w2";
        "Mod+4".focus-workspace = "w3";
        "Mod+5".focus-workspace = "w4";
        "Mod+6".focus-workspace = "w5";
        "Mod+7".focus-workspace = "w6";
        "Mod+8".focus-workspace = "w7";
        "Mod+9".focus-workspace = "w8";
        "Mod+0".focus-workspace = "w9";

        "Mod+Shift+1".move-column-to-workspace = "w0";
        "Mod+Shift+2".move-column-to-workspace = "w1";
        "Mod+Shift+3".move-column-to-workspace = "w2";
        "Mod+Shift+4".move-column-to-workspace = "w3";
        "Mod+Shift+5".move-column-to-workspace = "w4";
        "Mod+Shift+6".move-column-to-workspace = "w5";
        "Mod+Shift+7".move-column-to-workspace = "w6";
        "Mod+Shift+8".move-column-to-workspace = "w7";
        "Mod+Shift+9".move-column-to-workspace = "w8";
        "Mod+Shift+0".move-column-to-workspace = "w9";

        "Mod+Ctrl+H".set-column-width = "-5%";
        "Mod+Ctrl+L".set-column-width = "+5%";
        "Mod+Ctrl+J".set-window-height = "-5%";
        "Mod+Ctrl+K".set-window-height = "+5%";

        "Mod+WheelScrollDown".focus-column-left = empty;
        "Mod+WheelScrollUp".focus-column-right = empty;
        "Mod+Ctrl+WheelScrollDown".focus-workspace-down = empty;
        "Mod+Ctrl+WheelScrollUp".focus-workspace-up = empty;

        # Native screenshots support selection and copy directly to the clipboard.
        "Print".screenshot = empty;
        "Mod+Print".screenshot-screen = empty;
        "Mod+Shift+Print".screenshot-window = empty;
        "Mod+Shift+S".spawn = lib.getExe shell.suspend;

        # Audio & Media (dconf.nix + XF86Audio* keys)
        "Mod+V".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86AudioMicMute".spawn-sh =
          "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "Mod+F12".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
        "Mod+F11".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
        "Mod+F10".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioRaiseVolume".spawn-sh =
          "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume".spawn-sh =
          "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86MonBrightnessUp".spawn-sh = "${lib.getExe pkgs.brightnessctl} set +5%";
        "XF86MonBrightnessDown".spawn-sh = "${lib.getExe pkgs.brightnessctl} --min-value=1 set 5%-";

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

      workspaces = lib.genAttrs (map (i: "w${toString i}") (lib.range 0 9)) (_: { });

      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

      spawn-at-startup = [
        (lib.getExe shell.waybar)
        (lib.getExe shell.notifications)
        (lib.getExe shell.idle)
        [
          (lib.getExe pkgs.swaybg)
          "-i"
          "${../../_assets/backgroud-image.jpg}"
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

  security.pam.services.swaylock = { };
  programs.dconf.enable = lib.mkDefault true;
  services.upower.enable = true;

  environment.systemPackages = with pkgs; [
    shell.launcher
    shell.waybar
    shell.sessionMenu
    shell.lock
    swaybg
    playerctl
    brightnessctl
    xwayland-satellite
  ];
}
