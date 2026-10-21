{
  flake.nixosModules.gitea =
    { config, ... }:
    let
      http_address = "127.0.0.1";
      http_port = 3000;
      alias = "git";
      domain = "${alias}.${config.networking.domain}";
    in
    {
      services.gitea = {
        enable = true;
        settings = {
          server.HTTP_ADDR = http_address;
          server.HTTP_PORT = http_port;
          server.SSH_PORT = config.environment.sysConf.server.sshPort;
          server.DOMAIN = domain;
          webhook.ALLOWED_HOST_LIST = "*";
        };
      };

      services.nginx.virtualHosts = {
        "${domain}" = {
          serverAliases = [ alias ];
          locations."/" = {
            proxyPass = "http://${http_address}:${toString http_port}";
            extraConfig = ''
              client_max_body_size 512M;
              proxy_set_header Connection $http_connection;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };
        };
      };
    };
}
