{
  config,
  inputs,
  mkSystem,
  ...
}:
let
  inherit (inputs.nixpkgs) lib;
  inherit (config.flake) darwinModules;

  darwinModule =
    { lib, ... }:
    {
      system.stateVersion = lib.mkForce 6;
    };
in
{
  options.flake.darwinModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
    description = "Darwin modules.";
  };

  config.flake.lib.systemTypes.darwin = mkSystem {
    system = "aarch64-darwin";
    modules = [
      darwinModule
    ];
    sharedModules = [
      inputs.home-manager.darwinModules.home-manager
      darwinModules.nix
      darwinModules.nixvim
    ];
  };
}
