{
  config,
  inputs,
  self,
  ...
}:
let
  inherit (config.flake) nixosModules;
in
{
  flake.nixosModules.base =
    {
      lib,
      ...
    }:
    {
      imports = [
        inputs.disko.nixosModules.disko
        inputs.nixos-generators.nixosModules.all-formats
        nixosModules.nix
        nixosModules.nixvim
        nixosModules.shells
        nixosModules.tools
        nixosModules.users
        ./systemd.nix
        ./logind.nix
        ./networking.nix
        ./console.nix
        ./pkgs.nix
      ]
      ++ lib.optionals (builtins ? currentSystem) (
        builtins.filter builtins.pathExists [
          /etc/nixos/hardware-configuration.nix
          /etc/nixos/local.nix
        ]
      );

      _module.args.self = self;

      fileSystems."/" = lib.mkDefault {
        device = "none";
        fsType = "ext4";
      };

      system = {
        stateVersion = self.lib.stateVersion;
      };

      boot = {
        tmp.cleanOnBoot = true;
        blacklistedKernelModules = [ "snd_pcsp" ];
      };

      hardware = {
        enableAllFirmware = true;
        bluetooth = {
          enable = true;
          powerOnBoot = true;
        };
        wirelessRegulatoryDatabase = true;
      };

      time = {
        timeZone = "CET";
        hardwareClockInLocalTime = false;
      };

      environment.variables = {
        LIBVIRT_DEFAULT_URI = lib.mkForce "qemu:///system";
      };
    };
}
