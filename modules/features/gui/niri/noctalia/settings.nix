# Noctalia config.toml as Nix; see https://docs.noctalia.dev/noctalia/configuration/.
{ config, theme }:
{
  shell = {
    font_family = "Ubuntu";
    polkit_agent = true;
    telemetry_enabled = false;
    # Launched apps survive a shell restart, such as the one a rebuild triggers.
    launch_apps_as_systemd_services = true;
    keyboard_layout.custom_labels = {
      "English (US)" = "EN";
      Persian = "FA";
    };
  };

  theme = {
    mode = "dark";
    source = "builtin";
    builtin = "Catppuccin";
  };

  wallpaper = {
    enabled = true;
    fill_mode = "center";
    fill_color = "#000000";
    default.path = "${theme.wallpaper}";
  };

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

  # External monitors already appear as backlights through the ddcci kernel driver, which owns
  # their DDC address, so ddcutil would compete with it.
  brightness.enable_ddcutil = false;

  bar.main = {
    position = "top";
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
