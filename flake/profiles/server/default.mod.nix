{ config, self, ... }:
let
  inherit (config.flake) nixosModules;
  cfg = self.lib;
in
{
  flake.nixosModules.server =
    { ... }:
    {
      imports = [
        nixosModules.nginx
      ];

      users.users."${cfg.user.name}".openssh.authorizedKeys.keys = cfg.user.sshPubKeys;

      services.openssh = {
        enable = true;
        ports = [ cfg.server.sshPort ];
        openFirewall = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };
    };
}
