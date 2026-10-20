{ self, pkgs, ... }:
let
  commands = self.packages.${pkgs.stdenv.hostPlatform.system};
in
{

  environment.systemPackages = with pkgs; [
    commands.nixconf
    commands.nixup
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
