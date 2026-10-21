{ lib, ... }:
{
  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent yes
      Host *
        IdentitiesOnly yes
        TCPKeepAlive yes
        ServerAliveInterval 60
    '';
  };

  services.gnome.gcr-ssh-agent.enable = lib.mkForce false;

  security.pam = {
    sshAgentAuth.enable = true;
    services.sudo.sshAgentAuth = true;
  };

  home-manager.sharedModules = [
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [
          "~/.ssh/*.config"
          "~/.ssh/config.d/*.config"
        ];
        settings."*" = {
          ControlMaster = "auto";
          ControlPersist = "yes";
          ControlPath = "~/.ssh/master-%C";
        };
      };
    }
  ];
}
