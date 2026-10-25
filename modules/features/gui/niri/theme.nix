# Look and input settings shared by the compositor and whichever shell is active.
{ lib }:
{
  colors = {
    base = "#1e1e2e";
    surface = "#313244";
    text = "#cdd6f4";
    muted = "#6c7086";
    accent = "#89b4fa";
    urgent = "#f38ba8";
  };
  workspaces = map (i: "w${toString i}") (lib.range 0 4);
  wallpaper = ../assets/backgroud-image.jpg;
  xkb = {
    layout = "us,ir";
    options = "grp:alt_shift_toggle";
  };
}
