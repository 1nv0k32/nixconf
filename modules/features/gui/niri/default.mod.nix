{
  flake.nixosModules.gui-niri.imports = [
    ./compositor.nix
    ./session.nix
    ./super-tap.nix
  ];
}
