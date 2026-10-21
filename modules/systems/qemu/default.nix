{
  config,
  mkSystem,
  ...
}:
let
  qemuModule =
    { modulesPath, ... }:
    {
      imports = [
        "${modulesPath}/profiles/qemu-guest.nix"
      ];

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
in
{
  _module.args = { inherit qemuModule; };

  flake.lib.systemTypes.qemu = mkSystem {
    system = "x86_64-linux";
    modules = [
      qemuModule
    ];
    sharedModules = [
      config.flake.nixosModules.extra
    ];
  };
}
