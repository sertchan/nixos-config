{ pkgs, ... }:
{
  services.gvfs.enable = true; # GVfs daemon for trash support, MTP device mounts, and SMB/NFS protocols

  systemd.user.services.udiskie = {
    # Automounts USB flash drives, memory cards, and external hard drives upon connection
    enable = true;
    description = "Automounter for removable media";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.udiskie}/bin/udiskie";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
