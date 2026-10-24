{
  config,
  lib,
  pkgs,
  ...
}:
let
  pamAuth = service: {
    allowNullPassword = false;
    u2f.enable = config.security.pam.services.login.u2f.enable;
    u2f.control = config.security.pam.services.login.u2f.control;
    fprintAuth = config.services.fprintd.enable;
    # A supplied password should not wait for hardware authentication.
    rules.auth.unix.order = lib.mkIf (service.u2f.control == "sufficient") (
      service.rules.auth.u2f.order - 10
    );
    rules.auth.fprintd.settings = {
      timeout = 10;
      "max-tries" = 3;
    };
  };
in
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

  security.pam.services = {
    ly = pamAuth config.security.pam.services.ly;
    veila = pamAuth config.security.pam.services.veila;
  };

  systemd.user.services = {
    niri-polkit = {
      description = "Niri authentication agent";
      wantedBy = [ "niri.service" ];
      after = [ "niri.service" ];
      partOf = [ "niri.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Restart = "on-failure";
      };
    };

    veilad = {
      description = "Veila screen locker daemon";
      wantedBy = [ "niri.service" ];
      after = [ "niri.service" ];
      partOf = [ "niri.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.veila}/bin/veilad";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };
  };

  # Password storage uses pass-secret-service, not GNOME Keyring's portal.
  xdg.portal.config.niri."org.freedesktop.impl.portal.Secret" = lib.mkForce "none";
}
