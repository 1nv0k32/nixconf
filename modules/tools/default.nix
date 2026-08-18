{ ... }:
{
  imports = [
    ./nixvim.nix
    ./direnv.nix
    ./git.nix
    ./ssh.nix
    ./yubikey.nix
    ./tmux.nix
    ./fzf.nix
    ./kube.nix
    ./tor.nix
    ./sdr
  ];
}
