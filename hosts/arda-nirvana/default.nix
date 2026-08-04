{
  # ----- Module Imports -----
  imports = [
    ./system.nix
    ./tlp.nix

    ../../modules/core

    ../../modules/hardware/intel-gpu.nix
    ../../modules/hardware/bluetooth.nix

    ../../modules/services/zapret.nix
    ../../modules/services/dns-content-blocking.nix

    ../../modules/desktop
  ];

  # ----- Host Configuration -----
  networking.hostName = "arda-nirvana";
  time.timeZone = "Europe/Istanbul";

  system.stateVersion = "24.11";
}
