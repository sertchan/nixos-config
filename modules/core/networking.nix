{ lib, ... }: {
  # I use HaGeZi's Ctif DNS for blocking Phishing, Malware, Scam, Fake, Cryptojacking and other harmful domains
  # https://github.com/hagezi/dns-servers

  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        FallbackDNS = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
        LLMNR = "false";
        DNSSEC = "false";
        Domains = [ "~." ];
        DNSOverTLS = "true";
        Cache = "true";
        MulticastDNS = "false";
      };
    };
  };

  networking = {
    nameservers = lib.mkDefault [
      "162.55.58.40#ctif.hagezi.org"
      "2a01:4f8:1c19:6c19::1#ctif.hagezi.org"
    ];
    networkmanager.enable = true;
    usePredictableInterfaceNames = true; # Ensures network interface names remain consistent across reboots (e.g., enp3s0)
  };

  systemd = {
    services = {
      systemd-networkd.stopIfChanged = false; # Prevents network disconnection during system updates by not stopping the service on change
      systemd-resolved.stopIfChanged = false; # Prevents DNS resolution failure during system updates by keeping the service running
    };
  };
}
