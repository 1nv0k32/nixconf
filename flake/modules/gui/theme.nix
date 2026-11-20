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
  xkb = {
    layout = "us,ir";
    options = "grp:alt_shift_toggle";
  };
  # Ayu dark surface, so the backdrop matches app and shell backgrounds.
  background = "#0B0E14";
}
