{ mkSystem, ... }:
let
  nixosModule =
    { lib, ... }:
    {
      system.stateVersion = lib.mkForce 6;
    };
in
{
  flake.lib.systemTypes.darwin = mkSystem {
    system = "aarch64-darwin";
    modules = [
      nixosModule
    ];
  };
}
