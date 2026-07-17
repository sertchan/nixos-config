{ pkgs, ... }: {
  # For torrent management, I prefer to use qbittorrent-nox

  systemd.user.services.qbittorrent-nox = {
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
