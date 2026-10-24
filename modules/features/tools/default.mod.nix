{
  flake.nixosModules.tools =
    { ... }:
    {
      imports = [
        ./direnv.nix
        ./git.nix
        ./ssh.nix
        ./yubikey.nix
        ./tmux.nix
        ./fzf.nix
        ./kube.nix
        ./tor.nix
      ];
    };
}
