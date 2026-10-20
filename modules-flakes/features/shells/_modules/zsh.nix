{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    ohMyZsh = {
      enable = true;
      theme = "dst";
      plugins = [
        "git"
        "vi-mode"
      ];
      preLoaded = ''
        HYPHEN_INSENSITIVE=true
        COMPLETION_WAITING_DOTS=true
        VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
        VI_MODE_SET_CURSOR=true
      '';
    };
    interactiveShellInit = "";
  };
}
