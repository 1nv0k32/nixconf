{ inputs, self, ... }:
{
  flake.nixosModules.nix = {
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

      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
        dates = "daily";
        persistent = true;
      };

      optimise = {
        automatic = true;
        dates = [ "daily" ];
        persistent = true;
      };

      settings = {
        auto-optimise-store = true;
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
}
