{ config, ... }:
let
  media_dir1 = "${config.nixarr.mediaDir}/library";
  media_dir2 = "${config.nixarr.mediaDir}/sdcard";
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
        media_dir = [
          "V,${media_dir1}"
          "V,${media_dir2}"
        ];
      };
    };
  };
}
