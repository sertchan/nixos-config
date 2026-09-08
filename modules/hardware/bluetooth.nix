{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  dev = config.modules.device;
in {
  config = mkIf dev.hasBluetooth {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      disabledPlugins = ["sap"];
      settings = {
        General = {
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
          Experimental = true;
          FastConnectable = true;
        };
        Policy = {AutoEnable = true;};
      };
    };

    systemd.user.services.mpris-proxy = {
      enable = true;
      description = "MPRIS Proxy for Bluetooth devices";
      wantedBy = ["default.target"];
      after = [
        "network.target"
        "sound.target"
      ];
      serviceConfig = {
        ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
