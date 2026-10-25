{
  flake.nixosModules.gui-features =
    { lib, pkgs, ... }:
    let
      # Avatars are shown square; Noctalia's control center scales a wide picture by its long side
      # and then upscales it to fill the square, which blurs it.
      face = pkgs.runCommand "face.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
        magick ${../assets/backgroud-image.jpg} -gravity center -crop 1:1 +repage $out
      '';
    in
    {
      imports = [
        ./pkgs.nix
        ./xdg.nix
        ./chromium.nix
        ./gns3.nix
        ./localsend.nix
        ./winbox.nix
        ./wireshark.nix
        ./steam.nix
        ./appimage.nix
        ./waydroid.nix
        ./gpu-screen-recorder.nix
        ./terminal.nix
      ];

      home-manager.sharedModules = [
        (
          { config, ... }:
          {
            home.file = {
              "${config.home.homeDirectory}/.background-image".source = ../assets/backgroud-image.jpg;
              "${config.home.homeDirectory}/.face".source = face;
            };
          }
        )
      ];

      security.rtkit.enable = lib.mkDefault true;
      i18n.defaultLocale = "en_GB.UTF-8";

      services = {
        flatpak.enable = true;
        passSecretService.enable = lib.mkDefault true;
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
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = lib.mkForce false;
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
