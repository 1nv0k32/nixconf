{
  config,
  mkSystem,
  ...
}:
let
  nixosModule =
    { ... }:
    {
      imports = [
        ./_disko.nix
      ];

      hardware.parallels.enable = true;
    };
in
{
  flake.lib.systemTypes.parallels = mkSystem {
    modules = [
      nixosModule
    ];
    sharedModules = [
      config.flake.nixosModules.extra
    ];
  };
}
