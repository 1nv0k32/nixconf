{ inputs, ... }:
let
  inherit (inputs) self;
  lib = inputs.nixpkgs.lib;
  constructorType = lib.types.functionTo lib.types.raw;

  optionalLocalModules =
    paths:
    builtins.concatLists (map (path: lib.optional (builtins.pathExists path) (import path)) paths);

  nixosModules = [
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    inputs.nixvim.nixosModules.nixvim
    inputs.disko.nixosModules.disko
    inputs.nixos-generators.nixosModules.all-formats
    inputs.nixarr.nixosModules.default
  ];
  darwinModules = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nixvim.nixDarwinModules.nixvim
  ];
  pkgsModules = [
    ../pkgs/config.nix
  ];
  defaultModules = pkgsModules ++ [
    ../modules
    ../src
  ];
  baseModules = defaultModules ++ [
    ../src/base.nix
    ../pkgs/base.nix
  ];
  extraModules = baseModules ++ [
    ../overrides/initrd-luks.nix
    ../src/extra.nix
    ../pkgs/extra.nix
  ];
  guiModules = extraModules ++ [
    ../modules/gui
  ];
  systemModules = {
    base = nixosModules ++ baseModules;
    extra = nixosModules ++ extraModules;
    gui = nixosModules ++ guiModules;
    darwin = darwinModules ++ pkgsModules;
  };

  mkSystem =
    {
      system ? "aarch64-linux",
      modules,
      sharedModules ? systemModules.base,
      builder ? lib.nixosSystem,
    }:
    attrs:
    builder {
      inherit system;
      specialArgs = {
        inherit self;
        inherit (attrs) hostName domain;
      };
      modules = modules ++ sharedModules ++ optionalLocalModules attrs.modules;
    };
in
{
  # This legacy output contains host constructors and metadata, not NixOS modules.
  disabledModules = [ inputs.flake-parts.flakeModules.nixosModules ];

  options.flake.nixosModules = {
    remote = lib.mkOption {
      type = lib.types.str;
      description = "Remote flake URL used by the host management scripts.";
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
      description = "Default state version for host configurations.";
    };
    systemTypes = lib.mkOption {
      type = lib.types.lazyAttrsOf (
        lib.types.either constructorType (lib.types.lazyAttrsOf constructorType)
      );
      default = { };
      description = "Host constructors, optionally grouped by provider.";
    };
  };

  config = {
    _module.args = {
      inherit mkSystem systemModules;
    };

    flake.nixosModules = {
      remote = "git+https://codeberg.org/1nv0k32/nixconf";
      stateVersion = "26.05";
    };
  };
}
