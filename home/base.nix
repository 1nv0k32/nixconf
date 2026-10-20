{
  lib,
  stateVersion,
  gui,
  config,
  ...
}@attrs:
{
  imports = [
    (import ./libs/dconf.nix attrs)
    (import ./libs/terminal.nix attrs)
  ];

  home = {
    stateVersion = stateVersion;
    homeDirectory = "/home/${config.home.username}";
    file = lib.mkIf (gui.enable) {
      "${config.home.homeDirectory}/.background-image" = {
        source = ./bin/backgroud-image.jpg;
      };
      "${config.home.homeDirectory}/.face" = {
        source = ./bin/backgroud-image.jpg;
      };
    };
  };

  programs = {
    bash = {
      enable = true;
      bashrcExtra = ''
        if test -f ~/.bashrc.local; then
          . ~/.bashrc.local
        fi
      '';
    };

    zsh = {
      enable = true;
      initContent = ''
        if test -f ~/.zshrc.local; then
          . ~/.zshrc.local
        fi
      '';
    };

    ssh = {
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

    git = {
      enable = true;
    };
  };

  services = {
    flameshot = {
      enable = true;
      settings = {
        General = {
          disabledTrayIcon = true;
          useGrimAdapter = true;
          disabledGrimWarning = true;
        };
      };
    };
  };
}
