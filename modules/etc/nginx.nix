{ config, ... }:
let
  httpPort = 80;
  httpsPort = 443;
  giteaPort = "${config.services.gitea.settings.server.HTTP_PORT}";
  radarrPort = "${config.nixarr.radarr.port}";
  extraConfig = ''
    client_max_body_size 512M;
    proxy_set_header Connection $http_connection;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  '';
in
{

  networking.firewall.allowedTCPPorts = [
    httpPort
    httpsPort
  ];

  services.nginx = {
    enable = true;
    defaultHTTPListenPort = httpPort;
    defaultSSLListenPort = httpsPort;
    virtualHosts = {
      "git.${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${giteaPort}";
          extraConfig = extraConfig;
        };
      };
      "radarr.${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${radarrPort}";
          extraConfig = extraConfig;
        };
      };
    };
  };
}
