{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (config.flake) nixosModules;
in
{
  flake.nixosModules.mac = {
    imports = [
      inputs.nixos-mac.nixosModules.apple-silicon-support
      nixosModules.extra
      nixosModules.gui
      nixosModules.server
      nixosModules.nix-serve
    ];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

    hardware.asahi = {
      enable = true;
      avd.enable = false;
      extractPeripheralFirmware = lib.mkDefault false;
      peripheralFirmwareDirectory = lib.mkDefault null;
    };

    boot = {
      extraModprobeConfig = ''
        options hid_apple fnmode=3 iso_layout=-1 swap_opt_cmd=1
      '';
      loader.efi.canTouchEfiVariables = false;
    };

  };
}
