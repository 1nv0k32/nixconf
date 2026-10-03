{ self, ... }:
{
  imports = [
    (import "${self}/modules/services/nix-serve.nix")
  ];

  hardware.asahi = {
    avd.enable = false;
  };

  boot = {
    extraModprobeConfig = ''
      options hid_apple fnmode=3 iso_layout=-1 swap_opt_cmd=1
    '';
  };

  boot.loader.efi.canTouchEfiVariables = false;
  networking.networkmanager.enable = true;
}
