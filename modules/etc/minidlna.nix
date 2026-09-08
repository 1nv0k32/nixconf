{ config, ... }:
let
  media_dir = "${config.nixarr.mediaDir}/library";
in
{
  services = {
    minidlna = {
      enable = true;
      openFirewall = true;
      settings = {
        friendly_name = "${config.networking.hostName} DLNA";
        inotify = "yes";
        notify_interval = 30;
        media_dir = [ "V,${media_dir}" ];
      };
    };
  };
}
