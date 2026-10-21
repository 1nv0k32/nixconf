{
  config,
  inputs,
  mkSystem,
  serverModule,
  ...
}:
let
  nixosModule =
    { ... }:
    {
      imports = [
        (import ./_disko.nix)
        config.flake.nixosModules.wg
      ];
    };
in
{
  flake.lib.systemTypes.hetzner.amd = mkSystem {
    system = "x86_64-linux";
    modules = [
      inputs.srvos.nixosModules.hardware-hetzner-cloud
      serverModule
      nixosModule
    ];
  };

  flake.lib.systemTypes.hetzner.arm = mkSystem {
    modules = [
      inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
      serverModule
      nixosModule
    ];
  };
}
