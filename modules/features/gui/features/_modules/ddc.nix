{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    ddcutil-service
    ddcutil
    ddccontrol
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
  boot.kernelModules = [
    "i2c-dev"
    "ddcci_backlight"
  ];
  services.udev.extraRules = lib.mkAfter ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    SUBSYSTEM=="drm", ACTION=="add|change|remove", RUN+="${pkgs.systemd}/bin/systemctl --no-block start ddcci-bind.service"
  '';

  # ddcci cannot auto-probe on kernels >= 6.8, including DPMST adapters.
  systemd.services.ddcci-bind = {
    description = "Register external DDC monitors as backlights";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.python3.withPackages (ps: [ ps.smbus2 ])}/bin/python3 ${../_assets/ddcci.py}";
      TimeoutStartSec = 60;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
  };

  systemd.timers.ddcci-bind = {
    description = "Retry DDC discovery after link training or resume";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10s";
      OnUnitInactiveSec = "30s";
      AccuracySec = "1s";
    };
  };
}
