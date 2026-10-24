{
  self,
  lib,
  pkgs,
}:
let
  wrappers = self.inputs.wrapper-modules.wrappers;
  colors = {
    base = "#1e1e2e";
    surface = "#313244";
    text = "#cdd6f4";
    muted = "#6c7086";
    accent = "#89b4fa";
    urgent = "#f38ba8";
  };
  workspaces = map (i: "w${toString i}") (lib.range 0 4);
  wallpaper = ../assets/backgroud-image.jpg;
  # fuzzel wants RRGGBBAA without the leading hash.
  opaque = color: "${lib.removePrefix "#" color}ff";

  launcher = wrappers.fuzzel.wrap {
    inherit pkgs;
    prefixVar = [
      [
        "XDG_DATA_DIRS"
        ":"
        (lib.makeSearchPath "share" [
          pkgs.papirus-icon-theme
          pkgs.kdePackages.breeze-icons
          pkgs.adwaita-icon-theme
          pkgs.hicolor-icon-theme
        ])
      ]
    ];
    settings = {
      main = {
        font = "Ubuntu:size=12";
        terminal = "${lib.getExe pkgs.kitty} -e";
        prompt = ''"Search  "'';
        placeholder = "Applications";
        icon-theme = "Papirus-Dark";
        layer = "overlay";
        lines = 8;
        width = 40;
        line-height = 32;
        horizontal-pad = 20;
        vertical-pad = 16;
        inner-pad = 12;
      };
      colors = {
        background = opaque colors.base;
        text = opaque colors.text;
        prompt = opaque colors.accent;
        placeholder = opaque colors.muted;
        input = opaque colors.text;
        match = opaque colors.accent;
        selection = opaque colors.surface;
        selection-text = opaque colors.text;
        selection-match = opaque colors.accent;
        border = opaque colors.accent;
      };
      border = {
        width = 2;
        radius = 14;
      };
    };
  };

  # Matches swaybg's centered, unscaled wallpaper so locking does not visibly change the background.
  lockConfig = (pkgs.formats.toml { }).generate "veila-config.toml" {
    background = {
      mode = "file";
      path = wallpaper;
      scaling = "center";
      color = "#000000";
      blur_strength = 0;
      dim_strength = 0;
    };
  };

  lockDaemon = pkgs.writeShellScriptBin "niri-lock-daemon" ''
    exec ${pkgs.veila}/bin/veilad --config=${lockConfig} "$@"
  '';

  lock = import ./lock.nix { inherit lib pkgs lockDaemon; };
  fingerprintUnlock = import ./fingerprint-unlock.nix { inherit pkgs; };

  suspend = pkgs.writeShellScriptBin "niri-suspend" ''
    ${lib.getExe lock} || exit $?
    exec ${pkgs.systemd}/bin/systemctl suspend
  '';

  sessionMenu = pkgs.writeShellApplication {
    name = "niri-session-menu";
    text = ''
      if ! action=$(printf '%s\n' Lock Suspend 'Log out' Reboot 'Power off' |
        ${lib.getExe launcher} --dmenu --prompt 'Session  ' --lines 5); then
        exit 0
      fi

      case "$action" in
        Lock) exec ${lib.getExe lock} ;;
        Suspend) exec ${lib.getExe suspend} ;;
        'Log out'|Reboot|'Power off')
          if ! confirmation=$(printf '%s\n' Cancel "$action" |
            ${lib.getExe launcher} --dmenu --prompt 'Confirm  ' --lines 2); then
            exit 0
          fi
          [ "$confirmation" = "$action" ] || exit 0
          case "$action" in
            'Log out') exec ${lib.getExe pkgs.niri} msg action quit --skip-confirmation ;;
            Reboot) exec ${pkgs.systemd}/bin/systemctl reboot ;;
            'Power off') exec ${pkgs.systemd}/bin/systemctl poweroff ;;
          esac
          ;;
      esac
    '';
  };

  notifications = wrappers.mako.wrap {
    inherit pkgs;
    settings = {
      font = "Ubuntu 11";
      background-color = colors.base;
      text-color = colors.text;
      border-color = colors.accent;
      progress-color = "over ${colors.surface}";
      border-size = 2;
      border-radius = 12;
      padding = 16;
      margin = 12;
      width = 340;
      height = 180;
      anchor = "top-right";
      default-timeout = 6000;
      max-visible = 4;
      "urgency=critical" = {
        border-color = colors.urgent;
        default-timeout = 0;
      };
      "category=osd" = {
        anchor = "bottom-center";
        layer = "overlay";
        width = 240;
        height = 56;
        padding = "12,20";
        margin = "0,0,48,0";
        border-radius = 14;
        default-timeout = 1500;
        ignore-timeout = 1;
        history = 0;
        icons = 0;
        text-alignment = "center";
        format = "<b>%s</b>";
      };
    };
  };

  idle = pkgs.writeShellScriptBin "niri-idle" ''
    exec ${lib.getExe pkgs.swayidle} -w \
      lock '${lib.getExe lock}' \
      timeout 600 '${lib.getExe lock}' \
      timeout 900 '${lib.getExe pkgs.niri} msg action power-off-monitors' \
      resume '${lib.getExe pkgs.niri} msg action power-on-monitors' \
      before-sleep '${lib.getExe lock}'
  '';

  volume = pkgs.writeShellApplication {
    name = "niri-volume";
    runtimeInputs = [
      pkgs.libnotify
      pkgs.wireplumber
    ];
    text = ''
      case "''${1:-}" in
        up)
          wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
          target=@DEFAULT_AUDIO_SINK@
          kind=sink
          ;;
        down)
          wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-
          target=@DEFAULT_AUDIO_SINK@
          kind=sink
          ;;
        mute)
          wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
          target=@DEFAULT_AUDIO_SINK@
          kind=sink
          ;;
        mic-mute)
          wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
          target=@DEFAULT_AUDIO_SOURCE@
          kind=source
          ;;
        *)
          echo "Usage: niri-volume {up|down|mute|mic-mute}" >&2
          exit 2
          ;;
      esac

      if ! output=$(wpctl get-volume "$target" 2>/dev/null); then
        exit 0
      fi

      raw=''${output#Volume: }
      raw=''${raw%% *}
      dec=''${raw//[.,]/}
      percent=$(( 10#''${dec:-0} ))
      bar=$(( percent > 100 ? 100 : (percent < 0 ? 0 : percent) ))

      if [ "$kind" = source ]; then
        if [[ "$output" == *"[MUTED]"* ]]; then
          summary="󰍭  Microphone  Muted"
          bar=0
        else
          summary="󰍬  Microphone  ''${percent}%"
        fi
      else
        if [[ "$output" == *"[MUTED]"* ]]; then
          summary="󰝟  Volume  Muted"
          bar=0
        elif [ "$percent" -eq 0 ]; then
          summary="󰕿  Volume  0%"
        elif [ "$percent" -lt 50 ]; then
          summary="󰖀  Volume  ''${percent}%"
        else
          summary="󰕾  Volume  ''${percent}%"
        fi
      fi

      notify-send \
        --category=osd \
        --transient \
        --hint=string:x-canonical-private-synchronous:osd \
        --hint="int:value:''${bar}" \
        "$summary" || true
    '';
  };

  brightness = pkgs.writeShellApplication {
    name = "niri-brightness";
    runtimeInputs = [
      pkgs.brightnessctl
      pkgs.libnotify
      pkgs.systemd
    ];
    text = ''
      exec ${lib.getExe pkgs.python3} ${./assets/brightness.py} "$@"
    '';
  };

  # Ly draws on the console, where the ter-v24b font gives 12x24 px cells on the 1920 px panel.
  # Half-blocks make each image pixel a 12x12 px square, matching swaybg's unscaled placement.
  loginArt =
    pkgs.runCommand "niri-login-art.dur"
      { nativeBuildInputs = [ (pkgs.python3.withPackages (ps: [ ps.pillow ])) ]; }
      ''
        python3 ${./assets/login-art.py} --image ${wallpaper} --columns 160 --output $out
      '';

  waybar = import ./waybar.nix {
    inherit
      lib
      pkgs
      wrappers
      colors
      workspaces
      launcher
      sessionMenu
      lock
      volume
      brightness
      ;
  };
in
{
  inherit
    colors
    workspaces
    wallpaper
    loginArt
    launcher
    lockDaemon
    lock
    fingerprintUnlock
    suspend
    sessionMenu
    notifications
    idle
    volume
    brightness
    waybar
    ;
}
