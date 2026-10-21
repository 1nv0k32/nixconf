{
  flake.nixosModules.tools =
    { ... }:
    {
      imports = [
        ./_modules/direnv.nix
        ./_modules/git.nix
        ./_modules/ssh.nix
        ./_modules/yubikey.nix
        ./_modules/tmux.nix
        ./_modules/fzf.nix
        ./_modules/kube.nix
        ./_modules/tor.nix
      ];
    };
}
