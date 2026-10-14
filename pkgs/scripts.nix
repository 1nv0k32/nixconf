{ self, pkgs, ... }:
let
  bashOpts = ''
    set -euo pipefail
  '';
  remote = self.nixosModules.remote;
  nixconf = pkgs.writeShellScriptBin "nixconf" ''
    ${bashOpts}
    [ -f flake.nix ] && [ -f flake.lock ] || false
    cd $(git rev-parse --show-toplevel 2> /dev/null)
    while true; do
      read -p "Do you wish to update flake? [Ny] " yn
      case $yn in
        [Yy]* )
          nix flake update
          ;;
      esac
      git add -A
      pre-commit run --all-files || continue
      git --no-pager diff --cached
      WORK_BRANCH=$(git branch --show-current)
      read -p "Do you wish to commit these changes on $WORK_BRANCH? [Yn] " yn
      case $yn in
        [Nn]* )
          break
          ;;
        * )
          git commit -m "$(date +%Y/%m/%d-%H:%M:%S)"
          git push
          break
          ;;
      esac
    done
  '';
  nixup = pkgs.writeShellScriptBin "nixup" ''
    ${bashOpts}
    if [ $# -eq 0 ]; then
      sudo nixos-rebuild switch \
        --no-write-lock-file \
        --print-build-logs
      exit 0
    fi
    case "$1" in
      --boot)
        sudo nixos-rebuild boot \
          --no-write-lock-file \
          --print-build-logs
      --target)
        [ $# -eq 2 ] || { echo "usage: nixup [--target HOST]" >&2; exit 1; }
        nix build \
          --no-write-lock-file \
          --print-build-logs \
          --no-link \
          "${remote}?dir=flakes#nixosConfigurations.$2.config.system.build.toplevel"
        ;;
      *)
        echo "usage: nixup [--boot | --target HOST]" >&2
        exit 1
        ;;
    esac
  '';
in
{
  environment.systemPackages = with pkgs; [
    nixconf
    nixup
    git
    pre-commit
    nixfmt
  ];
}
