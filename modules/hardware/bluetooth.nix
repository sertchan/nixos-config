{ pkgs, ... }: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = [ "sap" ]; # SIM Access Profile (SAP) is not needed
    settings = {
      General = {
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
        Experimental = true;    # Show Bluetooth device battery levels
        FastConnectable = true; # Reduce connection latency
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  systemd.user.services.mpris-proxy = {
    # Forward media control keys (MPRIS) from Bluetooth devices
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
