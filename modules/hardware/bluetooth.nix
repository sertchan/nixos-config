{ pkgs, ... }: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = [ "sap" ]; # SIM Access Profile, not needed
    settings = {
      General = {
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
        Experimental = true; # for showing battery info
        FastConnectable = true; # reduces connection latency
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  systemd.user.services.mpris-proxy = {
    # Media player remote interfacing specification for bluetooth devices
    enable = true;
    description = "MPRIS Proxy for Bluetooth devices";
    wantedBy = [ "default.target" ];
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
}
