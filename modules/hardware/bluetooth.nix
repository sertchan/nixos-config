{ pkgs, ... }:
{
  # ----- Bluetooth Subsystem -----
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = [ "sap" ]; # Disable SIM Access Profile (unnecessary for modern desktop setups)

    settings = {
      General = {
        JustWorksRepairing = "always"; # Automatic re-pairing for devices using Just Works authentication
        MultiProfile = "multiple"; # Allow multiple Bluetooth profiles simultaneously
        Experimental = true; # Enable experimental features such as battery level reporting
        FastConnectable = true; # Reduce connection page scan interval for faster device reconnection
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  # ----- Media Control Proxy -----
  systemd.user.services.mpris-proxy = {
    # Proxies MPRIS media controls (play/pause/track) from Bluetooth headsets to media players
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
