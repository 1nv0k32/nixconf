# Look shared by niri, Noctalia and the greeter.
{ pkgs }:
{
  font = "Ubuntu";
  palette = {
    scheme = "Ayu";
    mode = "dark";
    # Ayu dark primary and outline, for niri's focus ring.
    accent = "#E6B450";
    outline = "#565B66";
  };
  cursor = {
    theme = "Adwaita";
    size = 24;
    package = pkgs.adwaita-icon-theme;
  };
  xkb.layout = "us,ir";
  background = "#000000";
}
