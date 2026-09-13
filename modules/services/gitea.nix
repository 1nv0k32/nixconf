{ config, ... }:
{
  services.gitea = {
    enable = true;
    settings = {
      server.HTTP_ADDR = "127.0.0.1";
      server.HTTP_PORT = 3000;
      server.SSH_PORT = config.environment.sysConf.server.sshPort;
      server.DOMAIN = "git.${config.networking.domain}";
      webhook.ALLOWED_HOST_LIST = "*";
    };
  };
}
