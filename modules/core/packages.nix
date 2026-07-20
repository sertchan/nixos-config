{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      curl
      wget

      stress
      pciutils
      lshw
      dmidecode
      sysstat
      smartmontools

      bind.dnsutils
      traceroute
      tcpdump
      mtr

      man-pages
    ];
  };
}
