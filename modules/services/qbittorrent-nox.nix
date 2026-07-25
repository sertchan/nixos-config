{ pkgs, ... }: {
  systemd.user.services.qbittorrent-nox = {
    # Headless qBittorrent daemon managed via Web UI interface
    enable = true;
    description = "Qbittorrent-nox";
    wants = [ "network-online.target" ];
    after = [
      "local-fs.target"
      "network-online.target"
      "nss-lookup.target"
    ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
