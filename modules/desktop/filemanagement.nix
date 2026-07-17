{ pkgs, ... }: {
  services.gvfs.enable = true; # Virtual filesystem, needed for trash/mtp/network mounts

  # Automounter for removable media such as usb, phones etc.
  systemd.user.services.udiskie = {
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
