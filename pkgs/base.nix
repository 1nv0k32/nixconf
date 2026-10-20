{
  self,
  lib,
  pkgs,
  ...
}:
let
  mkCommand =
    name:
    pkgs.writeShellScriptBin name ''
      set -euo pipefail
      exec ${lib.getExe pkgs.nix} run "git+${self.lib.remote}#${name}" -- "$@"
    '';
  nixconf = mkCommand "nixconf";
  nixup = mkCommand "nixup";
in
{
  environment.systemPackages = with pkgs; [
    nixconf
    nixup
    aria2
    curl
    dig
    file
    git
    git-crypt
    htop
    iperf3
    jq
    kubectl
    nixd
    nixos-anywhere
    openssl
    pre-commit
    screen
    sops
    tree
    unzip
    wget
    wireguard-tools
    yq
  ];
}
