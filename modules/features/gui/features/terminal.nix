{ lib, pkgs, ... }:
let
  fontFamily = "NotoMono Nerd Font Mono";
  fontSize = 14;
  shell = "${lib.getExe pkgs.tmux}";
in
{
  home-manager.sharedModules = [
    {
      programs.kitty = {
        enable = true;
        font = {
          name = fontFamily;
          size = fontSize;
        };
        settings = {
          remember_window_size = false;
          cursor_shape = "block";
          cursor_blink_interval = 0;
          enable_audio_bell = "no";
          shell = shell;
        };
      };
    }
  ];
}
