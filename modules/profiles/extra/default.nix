{ config, ... }:
let
  inherit (config.flake) nixosModules;
in
{
  flake.nixosModules.extra =
    { lib, ... }:
    {
      imports = [
        nixosModules.base
        ./_modules/pkgs.nix
      ];

      boot = {
        loader = {
          efi.canTouchEfiVariables = lib.mkDefault true;
          timeout = lib.mkDefault 0;
          systemd-boot = {
            enable = lib.mkDefault true;
            editor = lib.mkForce false;
            consoleMode = lib.mkDefault "max";
          };
        };
      };

      services = {
        fstrim.enable = true;
        fwupd.enable = true;
        printing.enable = true;
      };

      virtualisation = {
        libvirtd = {
          enable = true;
        };
        podman = {
          enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };
        vmVariant = {
          virtualisation = {
            vmVariantWithBootLoader = true;
            memorySize = 4094;
            cores = 4;
          };
        };
      };
    };
}
