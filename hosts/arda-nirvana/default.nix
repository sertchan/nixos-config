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
    };

    system = {
      audio.enable = true;
      bluetooth.enable = true;
    };
  };

  system.stateVersion = "24.11";
}
