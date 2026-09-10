{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.meta) getExe getExe';

  historyItemLimit = 100;
  maximumSelectionBytes = 16 * 1024 * 1024;
  passwordManagerMimeFilter = "^(?!x-kde-passwordManagerHint).+";
in {
  environment.variables.CLIPHIST_DB_PATH = "$XDG_RUNTIME_DIR/cliphist/db";

  systemd.user.services = {
    cliphist = {
      description = "Clipboard history service";
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      serviceConfig = {
        Environment = ["CLIPHIST_DB_PATH=%t/cliphist/db"];
        RuntimeDirectory = "cliphist";
        RuntimeDirectoryMode = "0700";
        UMask = "0077";
        ExecStartPre = "${getExe' pkgs.coreutils "rm"} -f %C/cliphist/db";
        ExecStart = "${getExe' pkgs.wl-clipboard "wl-paste"} --watch ${getExe pkgs.cliphist} -max-items ${toString historyItemLimit} store";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
    wl-clip-persist = {
      description = "Persistent clipboard for Wayland";
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${getExe pkgs.wl-clip-persist} --clipboard regular --all-mime-type-regex '${passwordManagerMimeFilter}' --selection-size-limit ${toString maximumSelectionBytes}";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
