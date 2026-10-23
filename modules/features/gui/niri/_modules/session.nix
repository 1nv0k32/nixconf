{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Niri handles layout switching through XKB, without an input-method daemon.
  i18n.inputMethod.enable = false;
  services.gnome.gnome-keyring.enable = false;

  services.displayManager = {
    defaultSession = "niri";
    ly = {
      enable = true;
      x11Support = false;
      settings = {
        allow_empty_password = true;
        clear_password = true;
        default_input = "password";
        initial_info_text = "Password, or empty+Enter then key/fingerprint";
        input_len = 48;
        shell = false;
      };
    };
  };

  security.pam.services.ly = {
    allowNullPassword = false;
    u2f.enable = config.security.pam.services.login.u2f.enable;
    u2f.control = config.security.pam.services.login.u2f.control;
    fprintAuth = config.services.fprintd.enable;
    # A supplied password should not wait for hardware authentication.
    rules.auth.unix.order = lib.mkIf (config.security.pam.services.ly.u2f.control == "sufficient") (
      config.security.pam.services.ly.rules.auth.u2f.order - 10
    );
    rules.auth.fprintd.settings = {
      timeout = 10;
      "max-tries" = 3;
    };
  };

  security.pam.services.hyprlock = {
    allowNullPassword = false;
    u2f.enable = config.security.pam.services.login.u2f.enable;
    u2f.control = config.security.pam.services.login.u2f.control;
    # Hyprlock runs fingerprint verification separately, without blocking PAM.
    fprintAuth = false;
  };

  systemd.user.services.niri-polkit = {
    description = "Niri authentication agent";
    wantedBy = [ "niri.service" ];
    after = [ "niri.service" ];
    partOf = [ "niri.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
    };
  };

  # Password storage uses pass-secret-service, not GNOME Keyring's portal.
  xdg.portal.config.niri."org.freedesktop.impl.portal.Secret" = lib.mkForce "none";
}
