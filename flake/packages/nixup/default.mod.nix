{ self, ... }:
{
  perSystem =
    { lib, pkgs, ... }:
    {
      packages.nixup = pkgs.writeShellScriptBin "nixup" ''
        set -euo pipefail

        if [ $# -eq 0 ]; then
          sudo ${lib.getExe pkgs.nixos-rebuild} switch \
            --impure \
            --no-write-lock-file \
            --print-build-logs \
            --flake "git+${self.lib.remote}"
          exit 0
        fi
        case "$1" in
          --boot)
            sudo ${lib.getExe pkgs.nixos-rebuild} boot \
              --impure \
              --no-write-lock-file \
              --print-build-logs \
              --flake "git+${self.lib.remote}"
            ;;
          --target)
            [ $# -eq 2 ] || { echo "usage: nixup [--target HOST]" >&2; exit 1; }
            ${lib.getExe pkgs.nix} build \
              --no-write-lock-file \
              --print-build-logs \
              --no-link \
              "git+${self.lib.remote}#nixosConfigurations.$2.config.system.build.toplevel"
            ;;
          *)
            echo "usage: nixup [--boot | --target HOST]" >&2
            exit 1
            ;;
        esac
      '';
    };
}
