{ lib, ... }: {
  # ----- Network Interfaces & Resolvers -----
  networking = {
    # Primary DNS resolvers using HaGeZi's Threat Intelligence Feed
    # Blocks ONLY Phishing, Malware, Scam, Fake, Cryptojacking and other harmful domains
    # https://github.com/hagezi/dns-servers
    nameservers = lib.mkDefault [
      "162.55.58.40#ctif.hagezi.org"
      "2a01:4f8:1c19:6c19::1#ctif.hagezi.org"
    ];

    networkmanager.enable = true;
    usePredictableInterfaceNames = true;
  };

  # ----- DNS Resolver Daemon -----
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSOverTLS = "true"; # Encrypt all DNS queries using DNS-over-TLS (DoT)
        Cache = "true";
        Domains = [ "~." ]; # Route all DNS lookups through systemd-resolved
        LLMNR = "false"; # Disable Link-Local Multicast Name Resolution to prevent local name spoofing
        MulticastDNS = "false"; # Disable mDNS to reduce redundant local broadcast traffic
        DNSSEC = "false"; # Rely on upstream HaGeZi resolver for DNSSEC validation

        FallbackDNS = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
      };
    };
  };

  # ----- Service Lifetime Options -----
  systemd.services = {
    # Prevent network connection or DNS drops during nixos-rebuild switch
    systemd-networkd.stopIfChanged = false;
    systemd-resolved.stopIfChanged = false;
  };
}
