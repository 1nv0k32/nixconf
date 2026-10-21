{
  config,
  inputs,
  mkSystem,
  ...
}:
let
  nixosModule =
    { config, lib, ... }:
    let
      cfg = config.environment.sysConf;
    in
    {
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
in
{
  flake.lib.systemTypes.avf = mkSystem {
    modules = [
      inputs.nixos-avf.nixosModules.avf
      config.flake.nixosModules.server
      nixosModule
    ];
  };
}
