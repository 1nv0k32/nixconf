{
  config,
  lib,
  ...
}:
let
  inherit (config.flake) nixosModules;
in
{
  flake.nixosModules.parallels = {
    imports = [
      nixosModules.extra
      ./_disko.nix
    ];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

    hardware.parallels.enable = true;
  };
}
