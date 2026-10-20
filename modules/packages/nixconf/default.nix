{
  perSystem =
    { lib, pkgs, ... }:
    {
      packages.nixconf = pkgs.writeShellScriptBin "nixconf" ''
        set -euo pipefail

        [ -f flake.nix ] && [ -f flake.lock ] || false
        cd "$(${lib.getExe pkgs.git} rev-parse --show-toplevel 2> /dev/null)"
        while true; do
          read -r -p "Do you wish to update flake? [Ny] " yn
          case $yn in
            [Yy]* )
              ${lib.getExe pkgs.nix} flake update
              ;;
          esac
          ${lib.getExe pkgs.git} add -A
          PATH="${lib.makeBinPath [ pkgs.nix ]}:$PATH" \
            ${lib.getExe pkgs.pre-commit} run --all-files || continue
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
