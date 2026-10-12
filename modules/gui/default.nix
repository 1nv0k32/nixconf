{ lib, pkgs, ... }:
{
  imports = [
    ./pkgs.nix
    ./xdg.nix
    ./ddc.nix
    ./chromium.nix
    ./gnome.nix
    ./ryoku.nix
    ./gns3.nix
    ./localsend.nix
    ./winbox.nix
    ./wireshark.nix
    ./steam.nix
    ./appimage.nix
    ./waydroid.nix
    ./gpu-screen-recorder.nix
  ];

  environment.sysConf.gui.enable = lib.mkDefault true;

  programs.dconf.enable = lib.mkDefault true;

  networking.networkmanager.enable = lib.mkDefault true;

  security.rtkit.enable = lib.mkDefault true;

  i18n.defaultLocale = "en_GB.UTF-8";

  services = {
    flatpak.enable = true;
    gnome.gnome-keyring.enable = lib.mkDefault true;
    pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.extraConfig."11-bluetooth-policy" = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };
    };

    displayManager = {
      gdm = {
        enable = lib.mkDefault true;
        autoSuspend = false;
      };
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = lib.mkForce false;
    };
  };

  fonts = {
    packages = with pkgs; [
      ubuntu-classic
      vazir-fonts
      nerd-fonts.noto
    ];
    enableDefaultPackages = true;
    fontconfig.defaultFonts = {
      serif = [
        "Vazirmatn"
        "DejaVu Serif"
      ];
      sansSerif = [
        "Vazirmatn"
        "DejaVu Sans"
      ];
    };
  };
}
