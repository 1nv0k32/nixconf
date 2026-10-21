{
  self,
  lib,
  pkgs,
  ...
}:
let
  empty = _: { };
  niriPackage = self.inputs.wrapper-modules.wrappers.niri.wrap {
    inherit pkgs;
    settings = {
      prefer-no-csd = empty;
      input = {
        focus-follows-mouse = empty;
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
        "Mod+S".spawn = lib.getExe pkgs.fuzzel;
        "Mod+E".spawn = lib.getExe pkgs.nautilus;
        "Mod+Tab".toggle-overview = empty;

        "Mod+F".maximize-column = empty;
        "Mod+G".fullscreen-window = empty;
        "Mod+Shift+F".toggle-window-floating = empty;
        "Mod+C".center-column = empty;

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

        # Screenshots & suspend (matching dconf.nix)
        "Print".spawn-sh =
          "${pkgs.util-linux}/bin/script --command ' ${lib.getExe pkgs.flameshot} gui --raw | ${pkgs.wl-clipboard}/bin/wl-copy ' /dev/null";
        "Mod+Print".screenshot = empty;
        "Mod+Shift+S".spawn-sh = "${pkgs.systemd}/bin/systemctl suspend";

        # Audio & Media (dconf.nix + XF86Audio* keys)
        "Mod+V".spawn-sh = "${pkgs.alsa-utils}/bin/amixer sset Capture toggle";
        "Mod+F12".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
        "Mod+F11".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
        "Mod+F10".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioRaiseVolume".spawn-sh =
          "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume".spawn-sh =
          "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute".spawn-sh = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

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
        gaps = 5;
        focus-ring = {
          width = 2;
          active-color = "#7fc8ff";
        };
      };

      workspaces =
        let
          settings = {
            layout.gaps = 5;
          };
        in
        {
          "w0" = settings;
          "w1" = settings;
          "w2" = settings;
          "w3" = settings;
          "w4" = settings;
          "w5" = settings;
          "w6" = settings;
          "w7" = settings;
          "w8" = settings;
          "w9" = settings;
        };

      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

      spawn-at-startup = [
        (lib.getExe pkgs.waybar)
        (lib.getExe (
          pkgs.writeShellScriptBin "wallpaper" "${lib.getExe pkgs.swaybg} -i ${../_assets/backgroud-image.jpg} -m fill"
        ))
      ];
    };
  };
in
{
  programs.niri = {
    enable = true;
    package = niriPackage;
  };

  environment.systemPackages = with pkgs; [
    fuzzel
    waybar
    swaybg
    playerctl
    xwayland-satellite
  ];
}
