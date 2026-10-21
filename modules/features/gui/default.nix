{
  flake.nixosModules.gui =
    { lib, pkgs, ... }:
    {
      imports = [
        ./_modules/pkgs.nix
        ./_modules/xdg.nix
        ./_modules/ddc.nix
        ./_modules/chromium.nix
        ./_modules/gnome.nix
        ./_modules/gns3.nix
        ./_modules/localsend.nix
        ./_modules/winbox.nix
        ./_modules/wireshark.nix
        ./_modules/steam.nix
        ./_modules/appimage.nix
        ./_modules/waydroid.nix
        ./_modules/gpu-screen-recorder.nix
        ./_modules/dconf.nix
        ./_modules/terminal.nix
      ];

      home-manager.sharedModules = [
        (
          { config, ... }:
          {
            home.file = {
              "${config.home.homeDirectory}/.background-image".source = ./_assets/backgroud-image.jpg;
              "${config.home.homeDirectory}/.face".source = ./_assets/backgroud-image.jpg;
            };

            services.flameshot = {
              enable = true;
              settings = {
                General = {
                  disabledTrayIcon = true;
                  useGrimAdapter = true;
                  disabledGrimWarning = true;
                };
              };
            };
          }
        )
      ];

      environment.sysConf.gui.enable = lib.mkDefault true;

      programs.dconf.enable = lib.mkDefault true;

      networking.networkmanager.enable = lib.mkDefault true;

      security.rtkit.enable = lib.mkDefault true;

      i18n.defaultLocale = "en_GB.UTF-8";

      services = {
        flatpak.enable = true;
        passSecretService.enable = lib.mkDefault true;
        gnome.gnome-keyring.enable = lib.mkForce false;
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
    };
}
