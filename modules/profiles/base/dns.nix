{ ... }:
{
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    resolved = {
      enable = true;
      settings.Resolve = {
        FallbackDNS = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        MulticastDNS = false;
        Cache = false;
        CacheFromLocalhost = false;
        DNSStubListener = false;
      };
    };
  };
}
