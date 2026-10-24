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

  boot.extraModulePackages = [
    (config.boot.kernelPackages.ddcci-driver.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./assets/ddcci-remove.patch ];
    }))
  ];
  hardware.i2c.enable = true;
  boot.kernelModules = [ "ddcci_backlight" ];
  services.udev.extraRules = lib.mkAfter ''
    SUBSYSTEM=="drm", ACTION=="add|change|remove", RUN+="${pkgs.systemd}/bin/systemctl --no-block start ddcci-bind.service"
  '';

  # ddcci cannot auto-probe on kernels >= 6.8, including DPMST adapters.
  systemd.services.ddcci-bind = {
    description = "Register external DDC monitors as backlights";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.python3.withPackages (ps: [ ps.smbus2 ])}/bin/python3 ${./assets/ddcci.py}";
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
