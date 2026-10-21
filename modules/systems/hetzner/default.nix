{
  config,
  inputs,
  ...
}:
let
  inherit (config.flake) nixosModules;
in
{
  flake.nixosModules.hetzner =
    { lib, pkgs, ... }:
    {
      imports = [
        inputs.srvos.nixosModules.hardware-hetzner-cloud
        nixosModules.base
        nixosModules.server
        nixosModules.wg
        ./_disko.nix
      ];

      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

      boot = lib.mkIf pkgs.stdenv.hostPlatform.isAarch64 {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
        kernelParams = [ "console=tty" ];
        initrd.kernelModules = [ "virtio_gpu" ];
      };
    };
}
