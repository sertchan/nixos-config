{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.meta) getExe;
in {
  services.gvfs.enable = true;

  systemd.user.services.udiskie = {
    description = "Automounter for removable media";
    wantedBy = ["default.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      ExecStart = getExe pkgs.udiskie;
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
