{
  config,
  ...
}:
let
  inherit (config.flake) nixosModules;
in
{
  flake.nixosModules.utm = {
    imports = [
      nixosModules.qemu
      nixosModules.gui
      ./_disko.nix
    ];

    nixpkgs.hostPlatform = "aarch64-linux";
  };
}
