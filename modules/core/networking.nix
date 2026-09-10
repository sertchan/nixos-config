{
  networking = {
    networkmanager = {
      enable = true;
      wifi.macAddress = "stable-ssid";
    };
  };

  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSOverTLS = "true";
        Domains = ["~."];
        LLMNR = "false";
        MulticastDNS = "false";
        FallbackDNS = [];
      };
    };
  };
}
