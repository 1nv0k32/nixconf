{ lib, config, ... }:
let
  cfg = config.environment.sysConf.server.wg;
in
{
  options.environment.sysConf = {
    server.wg = {
      enable = lib.mkEnableOption "server.wg";

      interface = lib.mkOption {
        type = lib.types.str;
        default = "wg0";
      };

      ip = lib.mkOption {
        type = lib.types.str;
        default = "10.100.0.1/24";
      };

      port = lib.mkOption {
        type = lib.types.int;
        default = 51820;
      };

      privateKeyFile = lib.mkOption {
        type = lib.types.str;
        default = "";
      };

      peers = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [
          {
            PublicKey = "";
            AllowedIPs = [ "10.100.0.2/32" ];
          }
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    systemd.network = {
      enable = true;

      netdevs."50-${cfg.interface}" = {
        netdevConfig = {
          Name = cfg.interface;
          Kind = "wireguard";
          MTUBytes = "1440";
        };
        wireguardConfig = {
          ListenPort = cfg.port;
          PrivateKeyFile = cfg.privateKeyFile;
          RouteTable = "main";
        };
        wireguardPeers = cfg.peers;
      };

      networks.${cfg.interface} = {
        matchConfig.Name = cfg.interface;
        address = [ cfg.ip ];
        networkConfig = {
          IPMasquerade = "ipv4";
          IPv4Forwarding = true;
        };
      };
    };
  };
}
