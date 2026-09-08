{pkgs, ...}: {
  systemd.user.services = {
    cliphist = {
      description = "Clipboard history service";
      wantedBy = ["default.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
    wl-clip-persist = {
      description = "Persistent clipboard for Wayland";
      wantedBy = ["default.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
