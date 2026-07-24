{ pkgs, ... }: {
  programs.niri.enable = true;

  # Auto-login to Hyprland on startup
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = "seyhan";
      };
      default_session = initial_session;
    };
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite # xwayland support
  ];
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true; # secret service
  systemd.user.services.niri.enableDefaultPath = false;
  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Force Electron/Chromium apps to use Wayland natively
}
