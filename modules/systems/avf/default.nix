{
  config,
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (config.flake) nixosModules;
  cfg = self.lib;
in
{
  flake.nixosModules.avf = {
    imports = [
      inputs.nixos-avf.nixosModules.avf
      nixosModules.base
      nixosModules.server
    ];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

    users.users."${cfg.user.name}" = {
      initialPassword = lib.mkForce null;
    };

    avf = {
      enableGraphics = false;
      defaultUser = cfg.user.name;
      enableConfigReplace = true;
      vmConfig = {
        memory_mib = lib.mkForce 8192;
      };
    };
  };
}
