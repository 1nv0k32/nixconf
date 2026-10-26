{ self, ... }:
{
  flake.nixosModules.gui-noctalia.imports = [
    self.inputs.noctalia.nixosModules.default
    self.inputs.noctalia-greeter.nixosModules.default
    ./shell.nix
    ./greeter.nix
  ];
}
