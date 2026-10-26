{ config, theme }:
{
  shell = {
    font_family = theme.font;
    polkit_agent = true;
    telemetry_enabled = false;
    launch_apps_as_systemd_services = true;
    niri_overview_type_to_launch_enabled = true;
    niri_overview_close_on_launch_enabled = true;
    keyboard_layout.custom_labels = {
      "English (US)" = "EN";
      Persian = "FA";
    };
  };

  theme = {
    inherit (theme.palette) mode;
    source = "builtin";
    builtin = theme.palette.scheme;
    pure_black_dark = true;
  };

  wallpaper.enabled = false;

  lockscreen = {
    enabled = true;
    fingerprint = config.services.fprintd.enable;
    allow_empty_password = config.security.pam.services.login.u2f.enable;
  };

  idle = {
    behavior_order = [
      "lock"
      "screen-off"
    ];
    behavior = {
      lock = {
        timeout = 600;
        action = "lock";
        enabled = true;
      };
      screen-off = {
        timeout = 900;
        action = "screen_off";
        enabled = true;
      };
    };
  };

  brightness.enable_ddcutil = true;

  widget.clock.format = "{:%Y/%b/%d %a %H:%M:%S}";

  bar.main = {
    position = "top";
    background_opacity = 1.0;
    radius = 0;
    concave_edge_corners = false;
    margin_ends = 0;
    margin_edge = 0;
    start = [
      "launcher"
      "workspaces"
      "media"
    ];
    center = [
      "caffeine"
      "notifications"
      "clock"
      "control-center"
      "session"
    ];
    end = [
      "keyboard_layout"
      "brightness"
      "volume"
      "bluetooth"
      "network"
      "battery"
      "tray"
    ];
  };
}
