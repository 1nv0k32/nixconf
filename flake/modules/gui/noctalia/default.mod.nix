{ inputs, ... }:
{
  flake.nixosModules.gui-noctalia.imports = [
    inputs.noctalia.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
    ./shell.nix
    ./greeter.nix
  ];
}
