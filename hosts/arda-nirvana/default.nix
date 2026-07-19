{
  imports = [
    # --- System & Power Profiles ---
    ./system.nix
    ./tlp.nix

    # --- Core Configuration ---
    ../../modules/core

    # --- Hardware Drivers ---
    ../../modules/hardware/intel-gpu.nix
    ../../modules/hardware/bluetooth.nix

    # --- Background Services ---
    ../../modules/services/zapret.nix
    ../../modules/services/dns-content-blocking.nix
    ../../modules/services/qbittorrent-nox.nix

    # --- Desktop ---
    ../../modules/desktop
  ];

  networking.hostName = "arda-nirvana";

  time.timeZone = "Europe/Istanbul";

  system.stateVersion = "24.11"; # DONT CHANGE unless you know what you're doing
}
