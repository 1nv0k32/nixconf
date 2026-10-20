{
  inputs,
  mkSystem,
  systemModules,
  ...
}:
let
  nixosModule =
    {
      self,
      ...
    }:
    {
      imports = [
        (import ./_disko.nix)
      ];

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
in
{
  flake.nixosModules.systemTypes.z13g2 = mkSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-z13-gen2
      nixosModule
    ];
    sharedModules = systemModules.gui;
  };
}
