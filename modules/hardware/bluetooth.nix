{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf;

  cfg = config.modules.system.bluetooth;
  dev = config.modules.device;
in {
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = dev.hasBluetooth;
        message = "${config.networking.hostName} runs the bluetooth stack without a radio to run it on. Set modules.device.hasBluetooth in the host configuration, or clear modules.system.bluetooth.enable.";
      }
    ];

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
      description = "MPRIS Proxy for Bluetooth devices";
      wantedBy = ["default.target"];
      after = [
        "network.target"
        "sound.target"
      ];
      serviceConfig = {
        ExecStart = getExe' pkgs.bluez "mpris-proxy";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
