{
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            FIRMWARE = {
              label = "FIRMWARE";
              size = "2048M";
              type = "EF00";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/firmware";
                mountOptions = [
                  "noatime"
                  "umask=0077"
                ];
              };
            };
            root = {
              label = "ROOT";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [
                  "data=journal"
                ];
              };
            };
          };
        };
      };
    };
  };
}
