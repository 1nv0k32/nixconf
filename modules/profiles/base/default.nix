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
      hostName,
      domain,
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
        ./_modules/systemd.nix
        ./_modules/logind.nix
        ./_modules/networking.nix
        ./_modules/console.nix
        ./_modules/pkgs.nix
      ];

      system = {
        stateVersion = self.lib.stateVersion;
      };

      boot = {
        tmp.cleanOnBoot = true;
        blacklistedKernelModules = [ "snd_pcsp" ];
      };

      networking = {
        inherit hostName domain;
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

      environment = {
        etc = {
          "nixos/flake.nix" = {
            source = "${self}/flakes/flake.nix";
            mode = "0444";
          };
        };
        variables = {
          LIBVIRT_DEFAULT_URI = lib.mkForce "qemu:///system";
        };
      };
    };
}
