{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  theme = import ../theme.nix { inherit lib; };
  pamAuth = import ../pam.nix { inherit config lib; };
in
{
  imports = [ self.inputs.noctalia-greeter.nixosModules.default ];

  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      session.default = "niri";
      appearance = {
        scheme = "Catppuccin";
        theme_mode = "dark";
        font_family = "Ubuntu";
        wallpaper = {
          path = "${theme.wallpaper}";
          fill_mode = "center";
          fill_color = "#000000";
        };
      };
      cursor = {
        theme = "Adwaita";
        size = 24;
        path = "${pkgs.adwaita-icon-theme}/share/icons";
      };
      keyboard = theme.xkb;
      # An empty password moves on to the security key, then the fingerprint reader.
      auth.allow_empty_password = true;
    };
  };

  security.pam.services.greetd = pamAuth config.security.pam.services.greetd true;
}
