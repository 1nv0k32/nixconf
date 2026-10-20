{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.environment.sysConf;
in
{
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
    sharedModules = [ (import "${self}/home/base.nix") ];
    extraSpecialArgs = {
      inherit (self.lib) stateVersion;
      inherit (config.environment.sysConf) gui;
      inherit pkgs;
    };
  };

  home-manager.users = {
    "${cfg.user.name}" =
      { ... }:
      {
        home.username = cfg.user.name;

        programs.git.settings.user = {
          name = cfg.git.username;
          email = cfg.git.email;
        };
      };

    "guest" =
      { ... }:
      {
        home.username = "guest";
      };
  };
}
