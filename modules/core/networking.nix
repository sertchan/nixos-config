{ lib, ... }: {
  # I use HaGeZi's Ctif DNS for blocking Phishing, Malware, Scam, Fake, Cryptojacking and other harmful domains
  # https://github.com/hagezi/dns-servers

  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        # Fallback DNS if primary servers are unreachable
        FallbackDNS = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
        LLMNR = "false"; # Disable LLMNR to prevent local network name spoofing
        DNSSEC = "false"; # Rely on upstream server for DNSSEC validation
        Domains = [ "~." ]; # Route all DNS traffic through resolved DNS servers
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

    # Local blocklist to redirect distracting domains to 0.0.0.0
    extraHosts = ''
      0.0.0.0 x.com
      0.0.0.0 nitter.net
      0.0.0.0 xcancel.com
      0.0.0.0 nitter.poast.org
      0.0.0.0 nitter.privacyredirect.com
      0.0.0.0 lightbrd.com
      0.0.0.0 nitter.space
      0.0.0.0 nitter.tiekoetter.com
      0.0.0.0 nuku.trabun.org
      0.0.0.0 nitter.catsarch.com
      0.0.0.0 nitter.kareem.one
      0.0.0.0 instagram.com
      0.0.0.0 anonyig.com
      0.0.0.0 save-free.com
      0.0.0.0 dolphinradar.com
      0.0.0.0 inflact.com
      0.0.0.0 imginn.com
    '';

    networkmanager.enable = true;
    usePredictableInterfaceNames = true; # Consistent interface names across reboots (e.g., enp3s0)
  };

  systemd = {
    # Prevent network/DNS interruption during nixos-rebuild switch
    services = {
      systemd-networkd.stopIfChanged = false;
      systemd-resolved.stopIfChanged = false;
    };
  };
}
