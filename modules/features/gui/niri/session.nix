{
  config,
  lib,
  pkgs,
  niriShell,
  ...
}:
let
  shell = niriShell;

  # Tied to niri.service, which imports WAYLAND_DISPLAY and NIRI_SOCKET before it reports ready.
  sessionService = description: command: {
    inherit description;
    wantedBy = [ "niri.service" ];
    after = [ "niri.service" ];
    partOf = [ "niri.service" ];
    serviceConfig = {
      ExecStart = command;
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  pamAuth = service: fingerprint: {
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
  };
in
{
  services.gnome.gnome-keyring.enable = false;
  # Waybar's battery module reads from UPower.
  services.upower.enable = true;

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
        animation = "dur_file";
        dur_file_path = "${shell.loginArt}";
        # The art is a single still frame, so redrawing every 5 ms (the default) only burns CPU.
        animation_frame_delay = 1000;
      };
    };
  };

  security.pam.services = {
    ly = pamAuth config.security.pam.services.ly true;
    # niri-fingerprint-unlock holds the reader while locked, so PAM must not wait on it.
    veila = pamAuth config.security.pam.services.veila false;
  };

  systemd.user.services = {
    niri-polkit = sessionService "Niri authentication agent" "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
    niri-bar = sessionService "Niri status bar" (lib.getExe shell.waybar);
    niri-notifications = sessionService "Niri notification daemon" (lib.getExe shell.notifications);
    niri-idle = sessionService "Niri idle locking" (lib.getExe shell.idle);
    niri-wallpaper = sessionService "Niri wallpaper" "${lib.getExe pkgs.swaybg} -i ${shell.wallpaper} -m center -c 000000";
    veilad = sessionService "Veila screen locker daemon" (lib.getExe shell.lockDaemon);

    niri-fingerprint-unlock = lib.mkIf config.services.fprintd.enable (
      sessionService "Unlock Veila with a fingerprint" (lib.getExe shell.fingerprintUnlock)
      // {
        after = [ "veilad.service" ];
      }
    );
  };

  # Password storage uses pass-secret-service, not GNOME Keyring's portal.
  xdg.portal.config.niri."org.freedesktop.impl.portal.Secret" = lib.mkForce "none";
}
