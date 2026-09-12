{
  imports = [
    ./system.nix
    ./tlp.nix
  ];

  networking.hostName = "arda-nirvana";
  time.timeZone = "Europe/Istanbul";

  modules = {
    device = {
      hasBluetooth = true;
      hasSound = true;
      wirelessInterface = "wlp0s20f3";
      wiredInterface = "enp6s0";
    };

    services.zapret.enable = true;

    system = {
      audio.enable = true;
      bluetooth.enable = true;
    };
  };

  system.stateVersion = "24.11";
}
