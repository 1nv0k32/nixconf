{ self, ... }:
{
  flake.nixosModules.gui.imports = with self.nixosModules; [
    gui-features
    gui-niri
    gui-noctalia
  ];
}
