# Look and input settings shared by niri, Noctalia and the greeter.
{ lib }:
{
  colors = {
    base = "#1e1e2e";
    surface = "#313244";
    accent = "#89b4fa";
  };
  workspaces = map (i: "w${toString i}") (lib.range 0 4);
  wallpaper = ../assets/backgroud-image.jpg;
  xkb = {
    layout = "us,ir";
    options = "grp:alt_shift_toggle";
  };
}
