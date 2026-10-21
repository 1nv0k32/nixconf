{ ... }:
{
  programs.bash = {
    completion.enable = true;
    interactiveShellInit = ''
      bind 'set completion-ignore-case on'
      bind 'set show-mode-in-prompt on'
      set -o vi
      set -o notify
      shopt -s autocd cdspell dirspell no_empty_cmd_completion
      shopt -s checkwinsize checkhash
      shopt -s histverify histappend histreedit cmdhist
      shopt -s globstar extglob
      export HISTIGNORE="&:ls:[bf]g:exit:reset:clear:cd*"
      export HISTCONTROL="ignoreboth:erasedups"
      export HISTSIZE=-1
      export HISTFILESIZE=-1
    '';
  };
}
