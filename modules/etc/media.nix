{ config, ... }:
let
  media_dir = "/home/media";
  user = "transmission";
  group = "users";
in
{
  users.users.minidlna = {
    extraGroups = [ group ];
  };

  systemd.tmpfiles.rules = [ "d ${media_dir} 0775 ${user} ${group}" ];

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
