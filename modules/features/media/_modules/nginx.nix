{ config, lib, ... }:
let
  extraConfig = ''
    client_max_body_size 512M;
    proxy_set_header Connection $http_connection;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  '';
  mkVirtualHost = alias: port: {
    name = "${alias}.${config.networking.domain}";
    value = {
      serverAliases = [ alias ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        extraConfig = extraConfig;
      };
    };
  };
in
{
  services.nginx = {
    virtualHosts = builtins.listToAttrs [
      (mkVirtualHost "transmission" config.services.transmission.settings.rpc-port)
      (mkVirtualHost "jellyfin" config.nixarr.jellyfin.port)
      (mkVirtualHost "seerr" config.nixarr.seerr.port)
      (mkVirtualHost "radarr" config.nixarr.radarr.port)
      (mkVirtualHost "sonarr" config.nixarr.sonarr.port)
      (mkVirtualHost "lidarr" config.nixarr.lidarr.port)
      (mkVirtualHost "bazarr" config.nixarr.bazarr.port)
      (mkVirtualHost "prowlarr" config.nixarr.prowlarr.port)
    ];
  };
}
