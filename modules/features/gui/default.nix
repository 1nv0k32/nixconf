{ self, ... }:
{
  flake.nixosModules.gui = {
    imports = with self.nixosModules; [
      gui-features
      gui-gnome
      gui-niri
    ];
  };
}
