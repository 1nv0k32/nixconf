{ config, ... }:
{
  networking.firewall = {
    allowedTCPPorts = [ 6443 ];
    trustedInterfaces = [ "cni+" ];
  };
  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    nodeName = config.networking.fqdn;
  };
}
