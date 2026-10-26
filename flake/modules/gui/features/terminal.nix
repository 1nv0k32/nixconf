{ lib, pkgs, ... }:
{
  # Installs kitty for every user; niri's Mod+Return starts it.
  home-manager.sharedModules = [
    {
      programs.kitty = {
        enable = true;
        font = {
          name = "NotoMono Nerd Font Mono";
          size = 14;
        };
        settings = {
          remember_window_size = false;
          cursor_shape = "block";
          cursor_blink_interval = 0;
          enable_audio_bell = "no";
          shell = lib.getExe pkgs.tmux;
        };
      };
    }
  ];
}
