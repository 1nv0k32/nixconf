{
  lib,
  pkgs,
  wrappers,
  colors,
  workspaces,
  launcher,
  sessionMenu,
  lock,
  volume,
  brightness,
}:
let
  template = wrappers.waybar.wrap {
    inherit pkgs;
    "style.css".path = ./assets/waybar.css;
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
        "niri/language"
        "network"
        "group/audio"
        "group/brightness"
        "power-profiles-daemon"
        "battery"
        "tray"
        "custom/session"
      ];

      "custom/launcher" = {
        format = "󱄅";
        tooltip-format = "Applications · Super+Space\nRight-click for the overview";
        on-click = lib.getExe launcher;
        on-click-right = "${lib.getExe pkgs.niri} msg action toggle-overview";
      };
      "niri/workspaces" = {
        format = "{icon}";
        format-icons =
          lib.listToAttrs (lib.imap1 (key: name: lib.nameValuePair name (toString key)) workspaces)
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
          format.today = "<b><span color='${colors.accent}'>{}</span></b>";
        };
      };
      "group/system" = {
        orientation = "horizontal";
        drawer = {
          click-to-reveal = true;
          transition-duration = 200;
        };
        modules = [
          "cpu#icon"
          "cpu"
          "memory"
          "disk"
        ];
      };
      "cpu#icon" = {
        interval = 5;
        format = "󰍛";
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
      "niri/language" = {
        format = "{short}";
        format-en = "EN";
        format-fa = "FA";
        on-click = "${lib.getExe pkgs.niri} msg action switch-layout next";
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
      # Drawer leaders must not have click actions: Waybar's click handler swallows every button,
      # which would stop the group from receiving the click that reveals it.
      "group/audio" = {
        orientation = "horizontal";
        drawer = {
          click-to-reveal = true;
          transition-duration = 200;
        };
        modules = [
          "pulseaudio#audio"
          "pulseaudio#level"
          "pulseaudio/slider"
        ];
      };
      "pulseaudio#audio" = {
        format = "{icon}";
        format-muted = "󰝟";
        format-icons.default = [
          "󰕿"
          "󰖀"
          "󰕾"
        ];
        format-source = "{volume}%";
        format-source-muted = "muted";
        tooltip-format = "{desc}\nVolume {volume}% · Microphone {format_source}\nClick: sliders · Scroll: adjust volume";
        on-scroll-up = "${lib.getExe volume} up";
        on-scroll-down = "${lib.getExe volume} down";
      };
      "pulseaudio#level" = {
        format = "{volume}%  {format_source}";
        format-muted = "Muted  {format_source}";
        format-source = "󰍬";
        format-source-muted = "󰍭";
        scroll-step = 5;
        max-volume = 100;
        tooltip-format = "{desc} · {volume}%\nClick: audio settings · Right: mute output · Middle: mute microphone";
        on-click = lib.getExe pkgs.pwvucontrol;
        on-click-right = "${lib.getExe volume} mute";
        on-click-middle = "${lib.getExe volume} mic-mute";
      };
      "pulseaudio/slider" = {
        min = 0;
        max = 100;
        orientation = "horizontal";
        target = "sink";
      };
      "group/brightness" = {
        orientation = "horizontal";
        drawer = {
          click-to-reveal = true;
          transition-duration = 200;
        };
        modules = [ "custom/brightness" ];
      };
      "custom/brightness" = {
        format = "󰃠";
        exec = "${lib.getExe brightness} status";
        return-type = "json";
        interval = 5;
        on-scroll-up = "${lib.getExe brightness} up";
        on-scroll-down = "${lib.getExe brightness} down";
      };
      power-profiles-daemon = {
        format = "{icon}";
        tooltip-format = "Power profile: {profile}\nDriver: {driver}\nClick to switch";
        format-icons = {
          default = "󰾅";
          performance = "󰓅";
          balanced = "󰾅";
          power-saver = "󰾆";
        };
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
        tooltip-format = "{capacity}% · {timeTo} · {power:0.1f} W";
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
in
pkgs.writeShellApplication {
  name = "waybar";
  text = ''
    exec ${pkgs.python3.withPackages (ps: [ ps.pyudev ])}/bin/python3 \
      ${./assets/waybar.py} \
      --template ${template}/waybar-config.json \
      --binary ${lib.getExe pkgs.waybar} \
      --style ${./assets/waybar.css} "$@"
  '';
}
