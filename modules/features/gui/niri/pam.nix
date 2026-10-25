# PAM settings for a login or unlock screen: password first, then a security key, then optionally fingerprint.
{ config, lib }:
service: fingerprint: {
  u2f.enable = config.security.pam.services.login.u2f.enable;
  u2f.control = config.security.pam.services.login.u2f.control;
  fprintAuth = fingerprint && config.services.fprintd.enable;
  # A supplied password should not wait for hardware authentication.
  rules.auth.unix.order = lib.mkIf (service.u2f.control == "sufficient") (
    service.rules.auth.u2f.order - 10
  );
  rules.auth.fprintd.settings = {
    timeout = 10;
    "max-tries" = 3;
  };
}
