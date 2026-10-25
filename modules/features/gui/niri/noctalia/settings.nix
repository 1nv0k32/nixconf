# Noctalia config.toml as Nix; see https://docs.noctalia.dev/noctalia/configuration/.
{ config }:
{
  shell = {
    font_family = "Ubuntu";
    polkit_agent = true;
    telemetry_enabled = false;
    # Launched apps survive a shell restart, such as the one a rebuild triggers.
    launch_apps_as_systemd_services = true;
    # Typing in niri's overview opens the launcher; launching an app closes the overview.
    niri_overview_type_to_launch_enabled = true;
    niri_overview_close_on_launch_enabled = true;
    window_switcher.mru = true;
    keyboard_layout.custom_labels = {
      "English (US)" = "EN";
      Persian = "FA";
    };
  };

  theme = {
    mode = "dark";
    source = "builtin";
    builtin = "Catppuccin";
    pure_black_dark = true;
  };

  # niri's black background shows instead.
  wallpaper.enabled = false;

  lockscreen = {
    enabled = true;
    fingerprint = config.services.fprintd.enable;
    # The lock screen authenticates against the login PAM stack, where an empty password
    # moves on to the security key.
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

  # 2026/Oct/25 Sun 11:31:22; a %S in the format makes the clock tick every second.
  widget.clock.format = "{:%Y/%b/%d %a %H:%M:%S}";

  # Full-width square bar; pure_black_dark above turns its surface colour black.
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
    center = [ "clock" ];
    end = [
      "sysmon"
      "caffeine"
      "keyboard_layout"
      "network"
      "bluetooth"
      "volume"
      "brightness"
      "power_profile"
      "battery"
      "tray"
      "notifications"
      "control-center"
      "session"
    ];
  };
}
