{ pkgs }:
pkgs.writeShellApplication {
  name = "niri-fingerprint-unlock";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.fprintd
    pkgs.systemd
    pkgs.veila
  ];
  text = ''
    # Prints the logind session Veila is guarding, only while it is locked.
    locked_session() {
      local line session="" active=false
      while IFS= read -r line; do
        case "$line" in
          session=*) session=''${line#session=} ;;
          active_lock=true) active=true ;;
        esac
      done < <(veila status 2>/dev/null || true)
      [ "$active" = true ] && [ -n "$session" ] && printf '%s\n' "$session"
    }

    verifier=""
    trap '[ -z "$verifier" ] || kill "$verifier" 2>/dev/null || true' EXIT

    while true; do
      if ! session=$(locked_session); then
        sleep 1
        continue
      fi

      fprintd-verify -f any >/dev/null 2>&1 &
      verifier=$!
      while kill -0 "$verifier" 2>/dev/null && locked_session >/dev/null; do
        sleep 0.5
      done

      if kill -0 "$verifier" 2>/dev/null; then
        # Unlocked another way; release the reader for sudo and polkit.
        kill "$verifier" 2>/dev/null || true
        wait "$verifier" 2>/dev/null || true
      elif wait "$verifier"; then
        busctl call org.freedesktop.login1 "$session" org.freedesktop.login1.Session Unlock || true
      else
        # No match, no enrolled finger, or reader busy: retry without spinning.
        sleep 1
      fi
      verifier=""
    done
  '';
}
