# The previous Waybar, fuzzel, mako, swayidle and Veila shell, with the ly display manager.
# Not imported by default; import it in place of ../noctalia in ../default.mod.nix to switch back.
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
  shell = import ./shell.nix {
    inherit
      self
      lib
      pkgs
      theme
      ;
    fingerprint = config.services.fprintd.enable;
  };

  spawn = package: args: { spawn = [ (lib.getExe package) ] ++ args; };
  volume = action: spawn shell.volume [ action ];
  brightness = action: spawn shell.brightness [ action ];
  player = action: spawn pkgs.playerctl [ action ];

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
in
{
  _module.args.niriShell = {
    actions = {
      launcher = spawn shell.launcher [ ];
      session = spawn shell.sessionMenu [ ];
      lock = spawn shell.lock [ ];
      suspend = spawn shell.suspend [ ];
      volumeUp = volume "up";
      volumeDown = volume "down";
      mute = volume "mute";
      micMute = volume "mic-mute";
      brightnessUp = brightness "up";
      brightnessDown = brightness "down";
      mediaNext = player "next";
      mediaPlayPause = player "play-pause";
      mediaPrevious = player "previous";
      mediaStop = player "stop";
    };
    binds = { };
    windowRules = [ ];
    settings = { };
  };

  environment.systemPackages = [
    shell.launcher
    shell.sessionMenu
    shell.lock
    shell.volume
    shell.brightness
    pkgs.playerctl
    pkgs.brightnessctl
    pkgs.papirus-icon-theme
  ];

  services.displayManager.ly = {
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

  security.pam.services = {
    ly = pamAuth config.security.pam.services.ly true;
    # Veila drives the reader itself over fprintd's D-Bus API, so PAM must not wait on it.
    veila = pamAuth config.security.pam.services.veila false;
  };

  systemd.user.services = {
    niri-polkit = sessionService "Niri authentication agent" "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
    niri-bar = sessionService "Niri status bar" (lib.getExe shell.waybar);
    niri-notifications = sessionService "Niri notification daemon" (lib.getExe shell.notifications);
    niri-idle = sessionService "Niri idle locking" (lib.getExe shell.idle);
    niri-wallpaper = sessionService "Niri wallpaper" "${lib.getExe pkgs.swaybg} -i ${shell.wallpaper} -m center -c 000000";
    veilad = sessionService "Veila screen locker daemon" (lib.getExe shell.lockDaemon);
  };
}
