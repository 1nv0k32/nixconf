{
  perSystem =
    { lib, pkgs, ... }:
    {
      packages.nixconf = pkgs.writeShellScriptBin "nixconf" ''
        set -euo pipefail

        update=false
        check=false
        for arg in "$@"; do
          case "$arg" in
            --update)
              update=true
              ;;
            --check)
              check=true
              ;;
            *)
              echo "usage: nixconf [--update] [--check]" >&2
              exit 1
              ;;
          esac
        done

        [ -f flake.nix ] && [ -f flake.lock ] || false
        cd "$(${lib.getExe pkgs.git} rev-parse --show-toplevel 2> /dev/null)"

        if [ "$update" = true ]; then
          ${lib.getExe pkgs.nix} flake update
        fi

        while true; do
          ${lib.getExe pkgs.git} add -A
          PATH="${lib.makeBinPath [ pkgs.nix ]}:$PATH" \
            ${lib.getExe pkgs.pre-commit} run --all-files || continue
          if [ "$check" = true ]; then
            ${lib.getExe pkgs.nix} flake check --all-systems
          fi
          ${lib.getExe pkgs.git} --no-pager diff --cached
          WORK_BRANCH=$(${lib.getExe pkgs.git} branch --show-current)
          read -r -p "Do you wish to commit these changes on $WORK_BRANCH? [Yn] " yn
          case $yn in
            [Nn]* )
              break
              ;;
            * )
              ${lib.getExe pkgs.git} commit -m "$(${lib.getExe' pkgs.coreutils "date"} +%Y/%m/%d-%H:%M:%S)"
              ${lib.getExe pkgs.git} push
              break
              ;;
          esac
        done
      '';
    };
}
