{
  flake.nixosModules.gui-niri.imports = [
    ./compositor.nix
    ./outputs.nix
    ./session.nix
  ];
}
