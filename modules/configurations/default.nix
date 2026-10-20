{
  inputs,
  inputModules,
  ...
}:
let
  inherit (inputs) self;
  lib = inputs.nixpkgs.lib;
  constructorType = lib.types.functionTo lib.types.raw;

  optionalLocalModules =
    paths:
    builtins.concatLists (map (path: lib.optional (builtins.pathExists path) (import path)) paths);

  pkgsModules = [
    ../../pkgs/config.nix
  ];
  defaultModules = pkgsModules ++ [
    ../default.nix
    ../../src
  ];
  baseModules = defaultModules ++ [
    ../../src/base.nix
    ../../pkgs/base.nix
  ];
  extraModules = baseModules ++ [
    ../../overrides/initrd-luks.nix
    ../../src/extra.nix
    ../../pkgs/extra.nix
  ];
  systemModules = {
    base = baseModules;
    extra = extraModules;
    darwin = pkgsModules;
  };

  mkSystem =
    {
      system ? "aarch64-linux",
      modules,
      sharedModules ? null,
    }:
    let
      isDarwin = (lib.systems.elaborate system).isDarwin;
      builder = if isDarwin then inputs.nix-darwin.lib.darwinSystem else lib.nixosSystem;
      platformModules = if isDarwin then inputModules.darwin else inputModules.nixos;
      profileModules =
        if sharedModules != null then
          sharedModules
        else if isDarwin then
          systemModules.darwin
        else
          systemModules.base;
    in
    attrs:
    builder {
      inherit system;
      specialArgs = {
        inherit self;
        inherit (attrs) hostName domain;
      };
      modules = modules ++ platformModules ++ profileModules ++ optionalLocalModules attrs.modules;
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
