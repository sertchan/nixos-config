{config, ...}: let
  iface = config.modules.device.wirelessInterface;
in {
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.${iface}.send_redirects" = 0;
  };

  services.radvd = {
    enable = true;
    config = ''
      interface ${iface} {
        AdvSendAdvert on;

        MinRtrAdvInterval 10;
        MaxRtrAdvInterval 30;

        AdvDefaultPreference high;

        route 2000::/3 {
          AdvRoutePreference high;
        };
      };
    '';
  };

  networking = {
    nftables = {
      enable = true;
      tables.gateway = {
        family = "ip6";
        content = ''
          chain output {
            type filter hook output priority 0; policy accept;
            oifname "${iface}" icmpv6 type nd-redirect counter drop
          }
        '';
      };
    };

    nat = {
      enable = true;
      externalInterface = iface;
      enableIPv6 = true;
      internalInterfaces = [iface];
    };

    firewall = {
      trustedInterfaces = [iface];
      filterForward = false;
    };
  };
}
