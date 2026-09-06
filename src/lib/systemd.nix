{ ... }:
let
  SYSTEMD_CONFIG = {
    LogLevel = "err";
    DefaultTimeoutStartSec = 30;
    DefaultTimeoutStopSec = 30;
    DefaultDeviceTimeoutSec = 30;
    DefaultMemoryAccounting = true;
    DefaultTasksAccounting = true;
  };
in
{
  boot.initrd.systemd = {
    enable = true;
    settings.Manager = SYSTEMD_CONFIG;
  };
  systemd = {
    settings.Manager = SYSTEMD_CONFIG;
    user.extraConfig = ''
      [Manager]
      DefaultTimeoutStartSec=30s
      DefaultTimeoutStopSec=30s
    '';
  };
}
