# Look shared by niri, Noctalia and the greeter.
{ pkgs }:
{
  font = "Ubuntu";
  palette = {
    scheme = "Catppuccin";
    mode = "dark";
  };
  cursor = {
    theme = "Adwaita";
    size = 24;
    package = pkgs.adwaita-icon-theme;
  };
  xkb.layout = "us,ir";
  background = "#000000";
}
