{
  config,
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (config.flake) darwinModules;
in
{
  options.flake = {
    darwinModules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = { };
      description = "Darwin modules.";
    };
    darwinConfigurations = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
      description = "Darwin system configurations.";
    };
  };

  config.flake = {
    darwinModules.darwin = {
      imports = [
        inputs.home-manager.darwinModules.home-manager
        darwinModules.nix
        darwinModules.nixvim
      ]
      ++ lib.optionals (builtins ? currentSystem) (
        builtins.filter builtins.pathExists [
          /etc/nix-darwin/local.nix
        ]
      );

      _module.args.self = self;

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
      system.stateVersion = lib.mkForce 6;
    };

    darwinConfigurations.nyxdarwin = inputs.nix-darwin.lib.darwinSystem {
      modules = [
        darwinModules.darwin
        {
          networking.hostName = "nyxdarwin";
        }
      ];
    };
  };
}
