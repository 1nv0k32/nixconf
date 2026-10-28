{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  theme = import ../theme.nix { inherit pkgs; };
  greetd = config.security.pam.services.greetd;
in
{
  services.displayManager.noctalia-greeter = {
    enable = true;
    package = pkgs.unstable.noctalia-greeter;
    settings = {
      session.default = "niri";
      user.default = self.lib.user.name;
      appearance = {
        inherit (theme.palette) scheme;
        theme_mode = theme.palette.mode;
        font_family = theme.font;
        wallpaper.path = "color:${theme.background}";
      };
      cursor = {
        inherit (theme.cursor) theme size;
        path = "${theme.cursor.package}/share/icons";
      };
      keyboard = theme.xkb;
      auth.allow_empty_password = greetd.u2f.enable;
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
