{
  config,
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
  flake.lib.systemTypes.utm = mkSystem {
    modules = [
      qemuModule
      nixosModule
    ];
    sharedModules = systemModules.extra ++ [
      config.flake.nixosModules.gui
    ];
  };
}
