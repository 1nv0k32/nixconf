{
  inputs = {
    # nixpkgs
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-test.url = "github:1nv0k32/nixpkgs";
    # tools
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openstack-nix = {
      url = "github:cobaltcore-dev/openstack-nix";
    };
    openstack-nix-dev = {
      url = "github:1nv0k32/openstack-nix";
    };
    # hardware
    nixos-avf.url = "github:nix-community/nixos-avf";
    nixos-mac = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self, ... }@inputs:
    with inputs;
    let
      # Definitions
      systems = {
        x86_64-linux = "x86_64-linux";
        aarch64-linux = "aarch64-linux";
        aarch64-darwin = "aarch64-darwin";
      };
      lib = nixpkgs.lib;
      optionalLocalModules =
        nix_paths:
        builtins.concatLists (
          lib.lists.forEach nix_paths (path: lib.optional (builtins.pathExists path) (import path))
        );

      # Modules
      nixosMods = [
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        nixvim.nixosModules.nixvim
        disko.nixosModules.disko
        nixos-generators.nixosModules.all-formats
      ];
      darwinMods = [
        home-manager.darwinModules.home-manager
        nixvim.nixDarwinModules.nixvim
      ];
      pkgsOverlays = [
        (import "${self}/pkgs/overlays.nix" inputs)
      ];
      defaultModules = pkgsOverlays ++ [
        (import "${self}/modules")
        (import "${self}/src")
      ];
      baseModules = defaultModules ++ [
        (import "${self}/src/base.nix")
        (import "${self}/pkgs/base.nix")
      ];
      extraModules = baseModules ++ [
        (import "${self}/overrides/initrd-luks.nix")
        (import "${self}/src/extra.nix")
        (import "${self}/pkgs/extra.nix")
      ];
      guiModules = extraModules ++ [
        (import "${self}/modules/gui")
      ];
    in
    {
      nixosModules = {
        stateVersion = "26.05";
        systemTypes = {
          # Thinkpad Z13 Gen2
          z13g2 =
            attrs:
            lib.nixosSystem {
              system = systems.x86_64-linux;
              specialArgs = {
                inherit self openstack-nix;
                inherit (attrs) hostName domain;
              };
              modules = [
                nixos-hardware.nixosModules.lenovo-thinkpad-z13-gen2
                (import "${self}/system/z13g2")
              ]
              ++ nixosMods
              ++ guiModules
              ++ optionalLocalModules attrs.modules;
            };
          # Mac
          mac =
            attrs:
            lib.nixosSystem {
              system = systems.aarch64-linux;
              specialArgs = {
                inherit self;
                inherit (attrs) hostName domain;
              };
              modules = [
                nixos-mac.nixosModules.apple-silicon-support
                (import "${self}/system/mac")
                (import "${self}/system/server.nix")
              ]
              ++ nixosMods
              ++ guiModules
              ++ optionalLocalModules attrs.modules;
            };
          # AVF
          avf =
            attrs:
            lib.nixosSystem {
              system = systems.aarch64-linux;
              specialArgs = {
                inherit self;
                inherit (attrs) hostName domain;
              };
              modules = [
                nixos-avf.nixosModules.avf
                (import "${self}/system/server.nix")
                (import "${self}/system/avf")
              ]
              ++ nixosMods
              ++ baseModules
              ++ optionalLocalModules attrs.modules;
            };
          # Hetzner
          hetzner.amd =
            attrs:
            lib.nixosSystem {
              system = systems.x86_64-linux;
              specialArgs = {
                inherit self;
                inherit (attrs) hostName domain;
              };
              modules = [
                srvos.nixosModules.hardware-hetzner-cloud
                (import "${self}/system/server.nix")
                (import "${self}/system/hetzner")
              ]
              ++ nixosMods
              ++ baseModules
              ++ optionalLocalModules attrs.modules;
            };
          hetzner.arm =
            attrs:
            lib.nixosSystem {
              system = systems.aarch64-linux;
              specialArgs = {
                inherit self;
                inherit (attrs) hostName domain;
              };
              modules = [
                srvos.nixosModules.hardware-hetzner-cloud-arm
                (import "${self}/system/server.nix")
                (import "${self}/system/hetzner")
              ]
              ++ nixosMods
              ++ baseModules
              ++ optionalLocalModules attrs.modules;
            };
          # WSL-NixOS
          wsl =
            attrs:
            lib.nixosSystem {
              system = systems.x86_64-linux;
              specialArgs = {
                inherit self;
                inherit (attrs) hostName domain;
              };
              modules = [
                nixos-wsl.nixosModules.wsl
                (import "${self}/system/wsl")
              ]
              ++ nixosMods
              ++ baseModules
              ++ optionalLocalModules attrs.modules;
            };
          # Darwin
          darwin =
            attrs:
            nix-darwin.lib.darwinSystem {
              system = systems.aarch64-darwin;
              specialArgs = {
                inherit self;
                inherit (attrs) hostName domain;
              };
              modules = [
                (import "${self}/system/darwin")
              ]
              ++ darwinMods
              ++ pkgsOverlays
              ++ optionalLocalModules attrs.modules;
            };
          # Raspberry Pi 5
          rpi5 =
            attrs:
            nixpkgs-unstable.lib.nixosSystem {
              system = systems.aarch64-linux;
              specialArgs = {
                inherit self;
                inherit (attrs) hostName domain;
              };
              modules = [
                nixos-hardware.nixosModules.raspberry-pi-5
                # (import "${self}/system/server.nix")
                (import "${self}/system/rpi5")
              ]
              ++ nixosMods
              ++ defaultModules
              ++ optionalLocalModules attrs.modules;
            };
          # QEMU
          qemu =
            attrs:
            lib.nixosSystem {
              system = systems.x86_64-linux;
              specialArgs = {
                inherit self;
                inherit (attrs) hostName domain;
              };
              modules = [
                (import "${self}/system/qemu.nix")
              ]
              ++ nixosMods
              ++ extraModules
              ++ optionalLocalModules attrs.modules;
            };
          # UTM
          utm =
            attrs:
            lib.nixosSystem {
              system = systems.aarch64-linux;
              specialArgs = {
                inherit self;
                inherit (attrs) hostName domain;
              };
              modules = [
                (import "${self}/system/qemu.nix")
                (import "${self}/system/utm")
              ]
              ++ nixosMods
              ++ guiModules
              ++ optionalLocalModules attrs.modules;
            };
          # Parallels
          parallels =
            attrs:
            lib.nixosSystem {
              system = systems.aarch64-linux;
              specialArgs = {
                inherit self;
                inherit (attrs) hostName domain;
              };
              modules = [
                (import "${self}/system/parallels")
              ]
              ++ nixosMods
              ++ extraModules
              ++ optionalLocalModules attrs.modules;
            };
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        # Definitions
        pkgs = import nixpkgs { inherit system; };

        # Packages
        nvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
          inherit pkgs;
          module = import "${self}/pkgs/src/nixvim.nix";
        };
      in
      {
        formatter = pkgs.nixfmt-tree;

        packages = {
          nvim = nvim;
        };

        devShells = {
          default = (import "${self}/shells/default.nix" { inherit pkgs lib; }).shell;
          kernel = (import "${self}/shells/kernel.nix" { inherit pkgs lib; }).shell;
          python = (import "${self}/shells/python.nix" { inherit pkgs lib; }).shell;
          go = (import "${self}/shells/go.nix" { inherit pkgs lib; }).shell;
          fhs = (import "${self}/shells/fhs.nix" { inherit pkgs lib; }).shell.env;
        };
      }
    );
}
