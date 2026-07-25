{ pkgs, ... }: {
  programs.niri.enable = true;

  environment = {
    systemPackages = with pkgs; [
      xwayland-satellite # xwayland support
    ];

    loginShellInit = ''
      if [ "$USER" != "root" ] && [ "$(id -u)" -ne 0 ] && [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && { [ "$XDG_VTNR" = "1" ] || [ "$(tty)" = "/dev/tty1" ]; }; then
        exec niri-session -l
      fi
    '';

    sessionVariables.NIXOS_OZONE_WL = "1"; # Force Electron/Chromium apps to use Wayland natively
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true; # secret service
  systemd.user.services.niri.enableDefaultPath = false;
}
