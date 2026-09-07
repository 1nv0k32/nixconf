{ ... }:
{
  nixarr = {
    enable = true;
    mediaDir = "/data/media";
    stateDir = "/data/media/.state/nixarr";

    jellyfin = {
      enable = true;
    };

    transmission = {
      enable = true;
      peerPort = 50000; # Set this to the port forwarded by your VPN
    };

    lidarr.enable = true;
    prowlarr.enable = true;
    seerr.enable = true;

    sonarr = {
      enable = true;
      settings-sync = {
        transmission.enable = true;
      };
    };

    radarr = {
      enable = true;
      settings-sync = {
        transmission.enable = true;
      };
    };

    bazarr = {
      enable = true;
      settings-sync = {
        sonarr = {
          enable = true;
          config = {
            sync_only_monitored_series = true;
            sync_only_monitored_episodes = true;
          };
        };
        radarr = {
          enable = true;
          config = {
            sync_only_monitored_movies = true;
          };
        };
      };
    };
  };
}
