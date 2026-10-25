{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  theme = import ../theme.nix { inherit lib; };
  greetd = config.security.pam.services.greetd;
in
{
  services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      session.default = "niri";
      user.default = self.lib.user.name;
      appearance = {
        scheme = "Catppuccin";
        theme_mode = "dark";
        font_family = "Ubuntu";
        # A color: path also overrides any wallpaper copied in by Noctalia's appearance sync.
        wallpaper.path = "color:#000000";
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

  security.pam.services.greetd = {
    u2f.enable = config.security.pam.services.login.u2f.enable;
    u2f.control = config.security.pam.services.login.u2f.control;
    fprintAuth = config.services.fprintd.enable;
    # A supplied password should not wait for hardware authentication.
    rules.auth.unix.order = lib.mkIf (greetd.u2f.control == "sufficient") (
      greetd.rules.auth.u2f.order - 10
    );
    rules.auth.fprintd.settings = {
      timeout = 10;
      "max-tries" = 3;
    };
  };
}
