{ config, lib, ... }:
{
  networking.networkmanager = {
    enable = lib.mkDefault (!config.networking.useNetworkd && !config.systemd.network.enable);
    wifi.backend = "iwd";
    dns = "systemd-resolved";
    settings.main = {
      no-auto-default = "*";
      systemd-resolved = true;
    };
  };
}
