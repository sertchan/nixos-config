{ pkgs, ... }: {
  systemd.user.services = {
    cliphist = {
      # Clipboard management for wayland environment
      enable = true;
      description = "Clipboard history service";
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
    wl-clip-persist = {
      # For making clipboard persistent
      description = "Persistent clipboard for Wayland";
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
