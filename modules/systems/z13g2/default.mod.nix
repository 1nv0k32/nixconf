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
  flake.nixosModules.z13g2 = {
    imports = [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-z13-gen2
      nixosModules.extra
      nixosModules.gui
      nixosModules.sdr
      ./disko.nix
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    boot = {
      extraModprobeConfig = ''
        options kvm_amd nested=1
      '';
      binfmt.emulatedSystems = [
        "x86_64-windows"
        "aarch64-linux"
      ];
    };

    hardware = {
      alsa.enablePersistence = true;
    };

    environment.variables = {
      "VDPAU_DRIVER" = "radeonsi";
      "LIBVA_DRIVER_NAME" = "radeonsi";
    };

    services = {
      fprintd.enable = true;
    };
  };
}
