{ inputs, ... }:
let
  inherit (inputs) self;
  lib = inputs.nixpkgs.lib;

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

  mkSystem =
    {
      system ? "aarch64-linux",
      modules,
      sharedModules ? nixosModules ++ baseModules,
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

  flake.nixosModules = {
    remote = "git+https://codeberg.org/1nv0k32/nixconf";
    stateVersion = "26.05";
    systemTypes = {
      # Thinkpad Z13 Gen2
      z13g2 = mkSystem {
        system = "x86_64-linux";
        modules = [
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-z13-gen2
          ../system/z13g2
        ];
        sharedModules = nixosModules ++ guiModules;
      };
      # Mac
      mac = mkSystem {
        modules = [
          inputs.nixos-mac.nixosModules.apple-silicon-support
          ../system/mac
          ../system/server
        ];
        sharedModules = nixosModules ++ guiModules;
      };
      # AVF
      avf = mkSystem {
        modules = [
          inputs.nixos-avf.nixosModules.avf
          ../system/server
          ../system/avf
        ];
      };
      # Hetzner
      hetzner = {
        amd = mkSystem {
          system = "x86_64-linux";
          modules = [
            inputs.srvos.nixosModules.hardware-hetzner-cloud
            ../system/server
            ../system/hetzner
          ];
        };
        arm = mkSystem {
          modules = [
            inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
            ../system/server
            ../system/hetzner
          ];
        };
      };
      # WSL-NixOS
      wsl = mkSystem {
        system = "x86_64-linux";
        modules = [
          inputs.nixos-wsl.nixosModules.wsl
          ../system/wsl
        ];
      };
      # Darwin
      darwin = mkSystem {
        system = "aarch64-darwin";
        builder = inputs.nix-darwin.lib.darwinSystem;
        modules = [
          ../system/darwin
        ];
        sharedModules = darwinModules ++ pkgsModules;
      };
      # Raspberry Pi 5
      rpi5 = mkSystem {
        modules = [
          inputs.nixos-hardware.nixosModules.raspberry-pi-5
          ../system/server
          ../system/rpi5
        ];
      };
      # QEMU
      qemu = mkSystem {
        system = "x86_64-linux";
        modules = [
          ../system/qemu.nix
        ];
        sharedModules = nixosModules ++ extraModules;
      };
      # UTM
      utm = mkSystem {
        modules = [
          ../system/qemu.nix
          ../system/utm
        ];
        sharedModules = nixosModules ++ guiModules;
      };
      # Parallels
      parallels = mkSystem {
        modules = [
          ../system/parallels
        ];
        sharedModules = nixosModules ++ extraModules;
      };
    };
  };
}
