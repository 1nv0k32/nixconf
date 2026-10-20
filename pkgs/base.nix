{ pkgs, ... }:
{
  imports = [
    (import ./scripts.nix)
  ];

  environment.systemPackages = with pkgs; [
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
