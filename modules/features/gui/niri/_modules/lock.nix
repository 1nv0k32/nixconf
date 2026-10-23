{ lib, pkgs }:
let
  # Keep swaylock -f's guarantee: return only once the compositor is locked.
  hyprlock = pkgs.hyprlock.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ../_assets/hyprlock-notify.patch ];
  });
in
pkgs.writeShellApplication {
  name = "niri-lock";
  runtimeInputs = [ pkgs.systemd ];
  text = ''
    if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      echo "Cannot lock: WAYLAND_DISPLAY is not set." >&2
      exit 1
    fi
    if [ ! -r /etc/pam.d/hyprlock ]; then
      echo "Apply the NixOS configuration before using the new lock screen." >&2
      exit 1
    fi

    unit=$(systemd-escape --template=niri-lock@.service -- "$WAYLAND_DISPLAY")
    if systemctl --user is-active --quiet "$unit"; then
      exit 0
    fi

    exec systemd-run --user --collect --unit="$unit" \
      --property=Type=notify --property=NotifyAccess=main \
      --property=TimeoutStartSec=10s \
      --setenv="WAYLAND_DISPLAY=$WAYLAND_DISPLAY" \
      --setenv=XDG_SESSION_TYPE=wayland \
      --setenv="XDG_CURRENT_DESKTOP=''${XDG_CURRENT_DESKTOP:-niri}" \
      ${lib.getExe hyprlock} --config ${../_assets/hyprlock.conf} \
      --grace 0 --immediate-render
  '';
}
