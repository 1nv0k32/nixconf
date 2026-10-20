{
  inputs,
  mkSystem,
  serverModule,
  ...
}:
let
  nixosModule =
    { self, ... }:
    {
      imports = [
        (import ./_disko.nix)
        (import "${self}/modules/services/wg.nix")
      ];
    };
in
{
  flake.nixosModules.systemTypes.hetzner.amd = mkSystem {
    system = "x86_64-linux";
    modules = [
      inputs.srvos.nixosModules.hardware-hetzner-cloud
      serverModule
      nixosModule
    ];
  };

  flake.nixosModules.systemTypes.hetzner.arm = mkSystem {
    modules = [
      inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
      serverModule
      nixosModule
    ];
  };
}
