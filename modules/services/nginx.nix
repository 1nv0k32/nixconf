{ ... }:
let
  httpPort = 80;
  httpsPort = 443;
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
    virtualHosts = { };
  };
}
