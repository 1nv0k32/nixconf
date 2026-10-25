# Look and input settings shared by niri, Noctalia and the greeter.
{ lib }:
{
  colors = {
    background = "#000000";
    surface = "#313244";
    accent = "#89b4fa";
  };
  workspaces = map (i: "w${toString i}") (lib.range 0 4);
  xkb.layout = "us,ir";
}
