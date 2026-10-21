{
  config,
  inputs,
  mkSystem,
  systemModules,
  serverModule,
  ...
}:
let
  nixosModule =
    { ... }:
    {
      imports = [
        config.flake.nixosModules.nix-serve
      ];

      hardware.asahi = {
        enable = true;
        avd.enable = false;
      };

      boot = {
        extraModprobeConfig = ''
          options hid_apple fnmode=3 iso_layout=-1 swap_opt_cmd=1
        '';
      };

      boot.loader.efi.canTouchEfiVariables = false;
      networking.networkmanager.enable = true;
    };
in
{
  flake.lib.systemTypes.mac = mkSystem {
    modules = [
      inputs.nixos-mac.nixosModules.apple-silicon-support
      nixosModule
      serverModule
    ];
    sharedModules = systemModules.extra ++ [
      config.flake.nixosModules.gui
    ];
  };
}
