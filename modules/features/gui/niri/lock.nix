{
  lib,
  pkgs,
  lockDaemon,
}:
pkgs.writeShellApplication {
  name = "niri-lock";
  runtimeInputs = [
    pkgs.systemd
    pkgs.veila
  ];
  text = ''
    if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      echo "Cannot lock: WAYLAND_DISPLAY is not set." >&2
      exit 1
    fi
    if [ ! -r /etc/pam.d/veila ]; then
      echo "Apply the NixOS configuration before using the new lock screen." >&2
      exit 1
    fi

    if ! veila health >/dev/null 2>&1; then
      systemctl --user start veilad.service 2>/dev/null ||
        systemd-run --user --collect --unit=veilad-fallback.service \
          --setenv="WAYLAND_DISPLAY=$WAYLAND_DISPLAY" \
          --setenv=XDG_SESSION_TYPE=wayland \
          --setenv="XDG_CURRENT_DESKTOP=''${XDG_CURRENT_DESKTOP:-niri}" \
          ${lib.getExe lockDaemon}
      for _ in $(seq 1 50); do
        veila health >/dev/null 2>&1 && break
        sleep 0.1
      done
    fi

    exec veila lock --wait-ready
  '';
}
