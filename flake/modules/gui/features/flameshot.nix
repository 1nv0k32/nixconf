{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.flameshot ];

  # Qt reads /etc/xdg as a fallback, so changes made in Flameshot's settings still
  # save to ~/.config/flameshot/flameshot.ini. Without grim, Flameshot on niri
  # captures through the screenshot portal.
  environment.etc."xdg/flameshot/flameshot.ini".text = ''
    [General]
    useGrimAdapter=true
    disabledGrimWarning=true
    disabledTrayIcon=true
  '';
}
