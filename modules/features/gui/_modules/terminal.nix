{ lib, pkgs, ... }:
let
  fontFamily = "NotoMono Nerd Font Mono";
  fontSize = 14;
  shell = "${lib.getExe pkgs.tmux}";
in
{
  home-manager.sharedModules = [
    {
      programs.gnome-terminal = {
        enable = true;
        themeVariant = "dark";
        showMenubar = false;
        profile."352f48f0-7279-422e-9e0a-95228e86bd1d" = {
          visibleName = "default";
          default = true;
          allowBold = true;
          audibleBell = false;
          showScrollbar = false;
          cursorShape = "block";
          cursorBlinkMode = "off";
          font = "${fontFamily} ${toString fontSize}";
          customCommand = shell;
        };
      };

      programs.kitty = {
        enable = true;
        font = {
          name = fontFamily;
          size = fontSize;
        };
        settings = {
          cursor_shape = "block";
          cursor_blink_interval = 0;
          enable_audio_bell = "no";
          shell = shell;
        };
      };
    }
  ];
}
