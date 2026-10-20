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
  imports = [ ../../gui ];

  flake.nixosModules.systemTypes.utm = mkSystem {
    modules = [
      qemuModule
      nixosModule
    ];
    sharedModules = systemModules.extra ++ [
      config.flake.modules.nixos.gui
    ];
  };
}
