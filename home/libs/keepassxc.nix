{
  lib,
  gui,
  ...
}:
{
  config = lib.mkIf (gui.enable) {
    xdg.autostart.enable = true;

    programs.keepassxc = {
      enable = true;
      autostart = true;
      settings = {
        FdoSecrets.Enabled = true;
      };
    };
  };
}
