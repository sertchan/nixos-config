{lib, ...}: let
  inherit (lib.modules) mkDefault;
in {
  networking = {
    nameservers = mkDefault [
      "162.55.58.40#ctif.hagezi.org"
      "2a01:4f8:1c19:6c19::1#ctif.hagezi.org"
    ];
    networkmanager.enable = true;
    usePredictableInterfaceNames = true;
  };

  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSOverTLS = "true";
        Cache = "true";
        Domains = ["~."];
        LLMNR = "false";
        MulticastDNS = "false";
        DNSSEC = "false";
        FallbackDNS = [
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
        ];
      };
    };
  };

  systemd.services = {
    systemd-networkd.stopIfChanged = false;
    systemd-resolved.stopIfChanged = false;
  };
}
