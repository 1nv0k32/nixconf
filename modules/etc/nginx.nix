{ config, ... }:
let
  httpPort = 80;
  httpsPort = 443;
  giteaPort = "${toString config.services.gitea.settings.server.HTTP_PORT}";
  transmissionPort = "${toString config.services.transmission.settings.rpc-port}";
  jellyfinPort = "${toString config.nixarr.jellyfin.port}";
  seerrPort = "${toString config.nixarr.seerr.port}";
  radarrPort = "${toString config.nixarr.radarr.port}";
  sonarrPort = "${toString config.nixarr.sonarr.port}";
  lidarrPort = "${toString config.nixarr.lidarr.port}";
  bazarrPort = "${toString config.nixarr.bazarr.port}";
  prowlarrPort = "${toString config.nixarr.prowlarr.port}";
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
      "transmission.${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${transmissionPort}";
          extraConfig = extraConfig;
        };
      };
      "jellyfin.${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${jellyfinPort}";
          extraConfig = extraConfig;
        };
      };
      "seerrPort.${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${seerrPort}";
          extraConfig = extraConfig;
        };
      };
      "radarr.${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${radarrPort}";
          extraConfig = extraConfig;
        };
      };
      "sonarr.${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${sonarrPort}";
          extraConfig = extraConfig;
        };
      };
      "lidarr.${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${lidarrPort}";
          extraConfig = extraConfig;
        };
      };
      "bazarr.${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${bazarrPort}";
          extraConfig = extraConfig;
        };
      };
      "prowlarr.${config.networking.domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${prowlarrPort}";
          extraConfig = extraConfig;
        };
      };
    };
  };
}
