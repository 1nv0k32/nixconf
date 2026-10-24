{ ... }:
{
  programs.direnv = {
    enable = true;
    loadInNixShell = true;
    silent = true;
    nix-direnv.enable = true;
    settings = {
      global = {
        hide_env_diff = true;
        load_dotenv = true;
        strict_env = true;
        warn_timeout = 0;
      };
    };
  };
}
