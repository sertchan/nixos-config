{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bind.dnsutils # Provides DNS lookup utilities (dig, nslookup)
    curl
    dmidecode
    lshw
    man-pages
    mtr # Network diagnostic tool combining traceroute and ping
    pciutils
    smartmontools # S.M.A.R.T. disk monitoring and diagnostic tools
    sysstat # Performance monitoring utilities (sar, iostat, mpstat)
    tcpdump
    traceroute
    wget
  ];
}
