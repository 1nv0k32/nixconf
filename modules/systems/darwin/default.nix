{ mkSystem, ... }:
let
  nixosModule =
    { lib, ... }:
    {
      system.stateVersion = lib.mkForce 6;

      nix = {
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
  flake.lib.systemTypes.darwin = mkSystem {
    system = "aarch64-darwin";
    modules = [
      nixosModule
    ];
  };
}
