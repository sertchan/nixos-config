{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bind.dnsutils
    curl
    dmidecode
    lshw
    man-pages
    mtr
    pciutils
    smartmontools
    sysstat
    tcpdump
    traceroute
    wget
  ];
}
