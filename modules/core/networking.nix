{ lib, ... }: {

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
    usePredictableInterfaceNames = true;
  };

  systemd = {
    services = {
      systemd-networkd.stopIfChanged = false;
      systemd-resolved.stopIfChanged = false;
    };
  };
}
