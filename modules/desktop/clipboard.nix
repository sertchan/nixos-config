{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.meta) getExe getExe';
in {
  systemd.user.services = {
    cliphist = {
      description = "Clipboard history service";
      wantedBy = ["default.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${getExe' pkgs.wl-clipboard "wl-paste"} --watch ${getExe pkgs.cliphist} store";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
    wl-clip-persist = {
      description = "Persistent clipboard for Wayland";
      wantedBy = ["default.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${getExe pkgs.wl-clip-persist} --clipboard both";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
