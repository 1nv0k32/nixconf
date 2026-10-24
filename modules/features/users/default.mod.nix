{ inputs, self, ... }:
let
  cfg = self.lib;
in
{
  flake.nixosModules.users =
    {
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      users.groups = {
        "ubridge".name = "ubridge";
        "i2c".name = "i2c";
      };

      users.users."${cfg.user.name}" = {
        initialPassword = "${cfg.user.name}";
        uid = 1000;
        isNormalUser = true;
        linger = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "podman"
          "libvirtd"
          "ubridge"
          "wireshark"
          "dialout"
          "i2c"
        ];
      };

      environment.etc.u2f_mappings.text = lib.mkAfter ''
        ${cfg.user.name}:${cfg.user.yubikeyU2F}
      '';

      users.users."guest" = {
        uid = 1001;
        isNormalUser = true;
        password = "guest";
      };

      home-manager = {
        extraSpecialArgs = {
          inherit pkgs;
        };
        sharedModules = [
          (
            { config, ... }:
            {
              home = {
                stateVersion = self.lib.stateVersion;
                homeDirectory = "/home/${config.home.username}";
              };
            }
          )
        ];
        users = {
          "${cfg.user.name}" = {
            home.username = cfg.user.name;
          };
          "guest" = {
            home.username = "guest";
          };
        };
      };
    };
}
