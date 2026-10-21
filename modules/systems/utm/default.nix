{
  config,
  mkSystem,
  qemuModule,
  ...
}:
let
  nixosModule =
    { ... }:
    {
      imports = [
        ./_disko.nix
      ];
    };
in
{
  flake.lib.systemTypes.utm = mkSystem {
    modules = [
      qemuModule
      nixosModule
    ];
    sharedModules = [
      config.flake.nixosModules.extra
      config.flake.nixosModules.gui
    ];
  };
}
