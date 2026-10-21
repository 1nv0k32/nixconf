{ self, pkgs, ... }:
let
  cfg = self.lib;
in
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

  home-manager = {
    sharedModules = [
      {
        programs.git.enable = true;
      }
    ];
    users."${cfg.user.name}".programs.git.settings.user = {
      name = cfg.git.username;
      email = cfg.git.email;
    };
  };
}
