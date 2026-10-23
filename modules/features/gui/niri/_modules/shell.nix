{
  self,
  lib,
  pkgs,
}:
let
  wrappers = self.inputs.wrapper-modules.wrappers;
  colors = {
    background = "#1e1e2e";
    surface = "#313244";
    text = "#cdd6f4";
    muted = "#6c7086";
    accent = "#89b4fa";
    urgent = "#f38ba8";
  };

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
        background = "1e1e2eff";
        text = "cdd6f4ff";
        prompt = "89b4faff";
        placeholder = "6c7086ff";
        input = "cdd6f4ff";
        match = "89b4faff";
        selection = "313244ff";
        selection-text = "cdd6f4ff";
        selection-match = "89b4faff";
        border = "89b4faff";
      };
      border = {
        width = 2;
        radius = 14;
      };
    };
  };

  lock = import ./lock.nix { inherit lib pkgs; };

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
      background-color = colors.background;
      text-color = colors.text;
      border-color = colors.accent;
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

  brightness = pkgs.writeShellApplication {
    name = "niri-brightness";
    runtimeInputs = [
      pkgs.brightnessctl
      pkgs.systemd
    ];
    text = ''
      exec ${lib.getExe pkgs.python3} ${../_assets/brightness.py} "$@"
    '';
  };

  waybarTemplate = wrappers.waybar.wrap {
    inherit pkgs;
    "style.css".path = ../_assets/waybar.css;
    settings = {
      layer = "top";
      position = "top";
      height = 40;
      margin-top = 8;
      margin-left = 10;
      margin-right = 10;
      spacing = 4;
      reload_style_on_change = true;
      on-sigusr2 = "reload";
      modules-left = [
        "custom/launcher"
        "niri/workspaces"
        "mpris"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "group/system"
        "idle_inhibitor"
        "network"
        "group/audio"
        "group/brightness"
        "battery"
        "tray"
        "custom/session"
      ];

      "custom/launcher" = {
        format = "󱄅";
        tooltip-format = "Applications · Super+S\nRight-click for the overview";
        on-click = lib.getExe launcher;
        on-click-right = "${lib.getExe pkgs.niri} msg action toggle-overview";
      };
      "niri/workspaces" = {
        format = "{icon}";
        format-icons =
          builtins.listToAttrs (
            map (i: {
              name = "w${toString i}";
              value = toString (i + 1);
            }) (lib.range 0 4)
          )
          // {
            default = "·";
          };
        all-outputs = false;
        on-scroll-up = "${lib.getExe pkgs.niri} msg action focus-workspace-up";
        on-scroll-down = "${lib.getExe pkgs.niri} msg action focus-workspace-down";
      };
      mpris = {
        format = "{status_icon} {dynamic}";
        format-paused = "{status_icon} {dynamic}";
        dynamic-order = [
          "title"
          "artist"
        ];
        dynamic-len = 22;
        max-length = 24;
        status-icons = {
          playing = "󰎆";
          paused = "󰏤";
          stopped = "󰓛";
        };
        tooltip-format = "{title}\n{artist} · {album}\nClick: play/pause · Right: next · Middle: previous";
      };
      clock = {
        format = "{:%a %d %b  ·  %H:%M}";
        format-alt = "{:%A, %d %B %Y  ·  %H:%M:%S}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          on-scroll = 1;
          format.today = "<b><span color='#89b4fa'>{}</span></b>";
        };
      };
      "group/system" = {
        orientation = "horizontal";
        drawer = {
          transition-duration = 200;
          children-class = "system-detail";
        };
        modules = [
          "custom/system"
          "cpu"
          "memory"
          "disk"
        ];
      };
      "custom/system" = {
        format = "󰍛";
        tooltip-format = "Hover for CPU, memory, and disk usage";
      };
      cpu = {
        interval = 5;
        format = "CPU {usage}%";
      };
      memory = {
        interval = 5;
        format = "RAM {percentage}%";
        tooltip-format = "{used:0.1f} / {total:0.1f} GiB";
      };
      disk = {
        interval = 60;
        format = "SSD {percentage_used}%";
        tooltip-format = "{free} free on {path}";
      };
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "󰅶";
          deactivated = "󰾪";
        };
        tooltip-format-activated = "Keep awake enabled · Click to allow automatic locking";
        tooltip-format-deactivated = "Auto-lock after 10 minutes · Click to keep awake";
      };
      network = {
        format-wifi = "󰤨";
        format-ethernet = "󰈀";
        format-disconnected = "󰤭";
        tooltip-format-wifi = "{essid} · {signalStrength}%\n{ipaddr}/{cidr}\n↓ {bandwidthDownBytes}  ↑ {bandwidthUpBytes}\nClick to manage connections";
        tooltip-format-ethernet = "{ifname}\n{ipaddr}/{cidr}\n↓ {bandwidthDownBytes}  ↑ {bandwidthUpBytes}\nClick to manage connections";
        tooltip-format-disconnected = "Disconnected · Click to connect";
        interval = 5;
        on-click = "${lib.getExe pkgs.kitty} --class floating.network -e ${pkgs.networkmanager}/bin/nmtui";
        on-click-right = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
      };
      "group/audio" = {
        orientation = "horizontal";
        drawer = {
          click-to-reveal = true;
          transition-duration = 200;
          children-class = "audio-detail";
        };
        modules = [
          "custom/audio"
          "pulseaudio"
          "pulseaudio/slider"
          "custom/audio-settings"
        ];
      };
      "custom/audio" = {
        format = "󰕾";
        tooltip-format = "Click: volume controls · Right: mute output · Middle: mute microphone";
        on-click-right = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-middle = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
        on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
      };
      pulseaudio = {
        format = "{volume}%  {format_source}";
        format-muted = "Muted  {format_source}";
        format-source = "󰍬";
        format-source-muted = "󰍭";
        format-icons.default = [
          "󰕿"
          "󰖀"
          "󰕾"
        ];
        scroll-step = 5;
        max-volume = 140;
        tooltip-format = "{desc}\nRight: mute output · Middle: mute microphone";
        on-click-right = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-middle = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      };
      "pulseaudio/slider" = {
        min = 0;
        max = 140;
        orientation = "horizontal";
        target = "sink";
      };
      "custom/audio-settings" = {
        format = "󰒓";
        tooltip-format = "Audio settings";
        on-click = lib.getExe pkgs.pwvucontrol;
      };
      "group/brightness" = {
        orientation = "horizontal";
        drawer = {
          click-to-reveal = true;
          transition-duration = 200;
          children-class = "brightness-detail";
        };
        modules = [ "custom/brightness" ];
      };
      "custom/brightness" = {
        format = "󰃠";
        tooltip-format = "Click: brightness sliders · Scroll: adjust all displays";
        on-scroll-up = "${lib.getExe brightness} up";
        on-scroll-down = "${lib.getExe brightness} down";
      };
      battery = {
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-full = "󰁹 Full";
        format-icons = [
          "󰂎"
          "󰁺"
          "󰁼"
          "󰁾"
          "󰂀"
          "󰁹"
        ];
        states = {
          warning = 25;
          critical = 10;
        };
        tooltip-format = "{timeTo} · {power:0.1f} W";
      };
      tray = {
        icon-size = 22;
        spacing = 8;
      };
      "custom/session" = {
        format = "󰐥";
        tooltip-format = "Session menu · Right-click to lock";
        on-click = lib.getExe sessionMenu;
        on-click-right = lib.getExe lock;
      };
    };
  };

  waybar = pkgs.writeShellApplication {
    name = "waybar";
    text = ''
      exec ${pkgs.python3.withPackages (ps: [ ps.pyudev ])}/bin/python3 \
        ${../_assets/waybar.py} \
        --template ${waybarTemplate}/waybar-config.json \
        --binary ${lib.getExe pkgs.waybar} \
        --style ${../_assets/waybar.css} "$@"
    '';
  };
in
{
  inherit
    colors
    launcher
    lock
    suspend
    sessionMenu
    notifications
    idle
    brightness
    waybar
    ;
}
