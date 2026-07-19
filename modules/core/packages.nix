{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      # --- Downloading & HTTP ---
      curl
      wget

      # --- Hardware & System Diagnostics ---
      stress
      pciutils
      lshw
      dmidecode
      sysstat
      smartmontools

      # --- Network Diagnostics ---
      bind.dnsutils
      traceroute
      tcpdump
      mtr

      # --- Documentation ---
      man-pages
    ];
  };
}
