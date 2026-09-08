{
  imports = [
    ./system.nix
    ./tlp.nix
  ];

  networking.hostName = "arda-nirvana";
  time.timeZone = "Europe/Istanbul";

  modules.device = {
    type = "laptop";
    hasBluetooth = true;
    hasSound = true;
  };

  system.stateVersion = "24.11";
}
