{pkgs, ...}: {
  services.gvfs.enable = true;

  systemd.user.services.udiskie = {
    description = "Automounter for removable media";
    wantedBy = ["default.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      ExecStart = "${pkgs.udiskie}/bin/udiskie";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
