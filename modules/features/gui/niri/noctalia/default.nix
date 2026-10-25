# Noctalia provides the bar, launcher, notifications, OSD, polkit agent, wallpaper, idle handling and
# lock screen; noctalia-greeter replaces ly as the login screen.
{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  theme = import ../theme.nix { inherit lib; };
  noctalia = lib.getExe config.programs.noctalia.package;
  msg = args: {
    spawn = [
      noctalia
      "msg"
    ]
    ++ args;
  };

  configFile = (pkgs.formats.toml { }).generate "noctalia-config.toml" (
    import ./settings.nix { inherit config theme; }
  );
  # Noctalia reads $NOCTALIA_CONFIG_HOME/noctalia/*.toml. Changes made in its Settings window go to
  # ~/.local/state/noctalia/settings.toml and override this file.
  configHome = pkgs.runCommand "noctalia-config" { } ''
    HOME=$TMPDIR ${noctalia} config validate ${configFile}
    mkdir -p $out/noctalia
    cp ${configFile} $out/noctalia/config.toml
  '';
in
{
  imports = [
    self.inputs.noctalia.nixosModules.default
    (import ./greeter.nix { inherit self; })
  ];

  _module.args.niriShell = {
    actions = {
      launcher = msg [
        "panel-toggle"
        "launcher"
      ];
      session = msg [
        "panel-toggle"
        "session"
      ];
      lock = msg [
        "session"
        "lock"
      ];
      suspend = msg [
        "session"
        "lock-and-suspend"
      ];
      volumeUp = msg [ "volume-up" ];
      volumeDown = msg [ "volume-down" ];
      mute = msg [ "volume-mute" ];
      micMute = msg [ "mic-mute" ];
      brightnessUp = msg [
        "brightness-up"
        "*"
        "5%"
      ];
      brightnessDown = msg [
        "brightness-down"
        "*"
        "5%"
      ];
      mediaNext = msg [
        "media"
        "next"
      ];
      mediaPlayPause = msg [
        "media"
        "toggle"
      ];
      mediaPrevious = msg [
        "media"
        "previous"
      ];
      mediaStop = msg [
        "media"
        "stop"
      ];
    };
    binds."Mod+Comma" = msg [ "settings-toggle" ];
    windowRules = [
      {
        matches = [ { app-id = "^dev\\.noctalia\\.Noctalia$"; } ];
        open-floating = true;
        default-column-width.fixed = 1080;
        default-window-height.fixed = 920;
      }
    ];
    # Lets notification actions and the launcher activate windows.
    settings.debug.honor-xdg-activation-with-invalid-serial = _: { };
  };

  programs.noctalia = {
    enable = true;
    # NetworkManager, Bluetooth, UPower and power-profiles-daemon. nixos-hardware's laptop profile
    # only enables TLP while power-profiles-daemon is off, so this also turns TLP off.
    recommendedServices.enable = true;
    systemd = {
      enable = true;
      # niri.service imports WAYLAND_DISPLAY and NIRI_SOCKET before it reports ready.
      target = "niri.service";
    };
  };
  # A changed config changes the unit, so a rebuild restarts the shell with it.
  systemd.user.services.noctalia.environment.NOCTALIA_CONFIG_HOME = "${configHome}";
}
