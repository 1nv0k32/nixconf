{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    git-review
    git-crypt
  ];

  programs.git = {
    enable = true;
    prompt.enable = true;
    config = {
      init.defaultBranch = "main";
      color.ui = "auto";
      fetch.all = true;
      fetch.prune = true;
      fetch.pruneTags = true;
      pull.rebase = true;
      push.autoSetupRemote = true;
      push.default = "current";
      rerere.enabled = true;
      format.signoff = true;
      alias.fpush = "push --force-with-lease";
      alias.acommit = "commit --amend --no-edit --all";
    };
  };
}
