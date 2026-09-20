{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.modules.system.bluetooth;
  dev = config.modules.device;
in {
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = dev.hasBluetooth;
        message = "${config.networking.hostName} enables the bluetooth stack but has no radio. Set modules.device.hasBluetooth in the host configuration, or clear modules.system.bluetooth.enable";
      }
    ];

    hardware.bluetooth = {
      enable = true;
      disabledPlugins = ["sap"];
      settings.General.MultiProfile = "multiple";
    };

    systemd.user.services.mpris-proxy = {
      wantedBy = ["default.target"];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
