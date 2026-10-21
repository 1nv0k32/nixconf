{ inputs, self, ... }:
let
  nixModule = {
    environment.variables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
      };
      overlays = [ self.overlays.default ];
    };

    nix = {
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      channel.enable = false;
      settings = {
        min-free = 512 * 1024 * 1024;
        max-free = 3000 * 1024 * 1024;
        download-buffer-size = 268435456;
        tarball-ttl = 0;
        flake-registry = "";
        trusted-users = [ "@wheel" ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };
  };
in
{
  flake = {
    nixosModules.nix = {
      imports = [ nixModule ];

      nix = {
        gc = {
          automatic = true;
          options = "--delete-older-than 3d";
          dates = "daily";
          persistent = true;
        };

        optimise = {
          automatic = true;
          dates = [ "daily" ];
          persistent = true;
        };

        settings.auto-optimise-store = true;
      };
    };

    darwinModules.nix = {
      imports = [ nixModule ];
    };
  };
}
