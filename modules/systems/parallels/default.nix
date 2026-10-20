{ mkSystem, systemModules, ... }:
let
  nixosModule =
    { ... }:
    {
      imports = [
        (import ./_disko.nix)
      ];

      hardware.parallels.enable = true;
    };
in
{
  flake.lib.systemTypes.parallels = mkSystem {
    modules = [
      nixosModule
    ];
    sharedModules = systemModules.extra;
  };
}
