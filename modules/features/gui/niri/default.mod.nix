{ self, ... }:
{
  flake.nixosModules.gui-niri = {
    imports = [
      self.inputs.noctalia.nixosModules.default
      self.inputs.noctalia-greeter.nixosModules.default
      ./compositor.nix
      ./session.nix
      ./noctalia
    ];
  };
}
