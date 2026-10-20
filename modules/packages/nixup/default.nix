{ self, ... }:
{
  perSystem =
    { lib, pkgs, ... }:
    {
      packages.nixup = pkgs.writeShellScriptBin "nixup" ''
        set -euo pipefail

        if [ $# -eq 0 ]; then
          sudo ${lib.getExe pkgs.curl} -sfL "${self.lib.remote}/raw/branch/main/flakes/flake.nix" -o /etc/nixos/flake.nix || true
          sudo ${lib.getExe pkgs.nixos-rebuild} switch \
            --no-write-lock-file \
            --print-build-logs
          exit 0
        fi
        case "$1" in
          --boot)
            sudo ${lib.getExe pkgs.nixos-rebuild} boot \
              --no-write-lock-file \
              --print-build-logs
            ;;
          --target)
            [ $# -eq 2 ] || { echo "usage: nixup [--target HOST]" >&2; exit 1; }
            ${lib.getExe pkgs.nix} build \
              --no-write-lock-file \
              --print-build-logs \
              --no-link \
              "git+${self.lib.remote}?dir=flakes#nixosConfigurations.$2.config.system.build.toplevel"
            ;;
          *)
            echo "usage: nixup [--boot | --target HOST]" >&2
            exit 1
            ;;
        esac
      '';
    };
}
