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

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command =
      "${lib.getExe pkgs.tuigreet} --time --remember "
      + "--cmd ${config.programs.niri.package}/bin/niri-session";
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
