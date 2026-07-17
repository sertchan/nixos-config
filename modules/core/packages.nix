{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      curl
      wget
      stress
      pciutils
      lshw
      man-pages
      dmidecode
      sysstat
      smartmontools
      bind.dnsutils
      traceroute
      tcpdump
      mtr
    ];
  };
}
