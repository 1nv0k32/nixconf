{
  mkSystem,
  systemModules,
  qemuModule,
  ...
}:
let
  nixosModule =
    { ... }:
    {
      imports = [
        (import ./_disko.nix)
      ];
    };
in
{
  flake.nixosModules.systemTypes.utm = mkSystem {
    modules = [
      qemuModule
      nixosModule
    ];
    sharedModules = systemModules.gui;
  };
}
