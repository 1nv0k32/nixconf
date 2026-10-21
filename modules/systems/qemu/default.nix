{
  config,
  lib,
  ...
}:
let
  inherit (config.flake) nixosModules;
in
{
  flake.nixosModules.qemu =
    { modulesPath, ... }:
    {
      imports = [
        "${modulesPath}/profiles/qemu-guest.nix"
        nixosModules.extra
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      boot = {
        initrd.kernelModules = [
          "virtio_pci"
          "xhci_pci"
          "usb_storage"
          "usbhid"
        ];
      };

      services = {
        spice-vdagentd.enable = true;
      };
    };
}
