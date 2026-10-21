{
  config,
  inputs,
  mkSystem,
  ...
}:
let
  nixosModule =
    { ... }:
    {
      imports = [
        ./_disko.nix
        config.flake.nixosModules.wg
      ];
    };
in
{
  flake.lib.systemTypes.hetzner.amd = mkSystem {
    system = "x86_64-linux";
    modules = [
      inputs.srvos.nixosModules.hardware-hetzner-cloud
      config.flake.nixosModules.server
      nixosModule
    ];
  };

  flake.lib.systemTypes.hetzner.arm = mkSystem {
    modules = [
      inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
      config.flake.nixosModules.server
      nixosModule
    ];
  };
}
