let
  device = "/dev/vda";
  main = "main";
  ESP = "ESP";
  root = "root";
in
{
  disko.devices = {
    disk = {
      "${main}" = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            "${ESP}" = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            "${root}" = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                askPassword = true;
                postCreateHook = ''
                  systemd-cryptenroll \
                    --fido2-device auto \
                    --fido2-with-user-verification no \
                    --fido2-with-user-presence no \
                    /dev/disk/by-partlabel/disk-${main}-${root}
                '';
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
