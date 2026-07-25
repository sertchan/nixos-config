{ pkgs, ... }: {
  # ----- Wayland Compositor -----
  programs.niri.enable = true;

  environment = {
    systemPackages = with pkgs; [
      xwayland-satellite # XWayland bridge daemon providing X11 client support for Niri
    ];

    # Auto-start Niri session on TTY1 login for non-root users
    loginShellInit = ''
      if [ "$USER" != "root" ] && [ "$(id -u)" -ne 0 ] && [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && { [ "$XDG_VTNR" = "1" ] || [ "$(tty)" = "/dev/tty1" ]; }; then
        exec niri-session -l
      fi
    '';

    sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Force Electron and Chromium applications to run on Wayland natively
    };
  };

  # ----- Desktop Authentication & Secrets -----
  security.polkit.enable = true; # Polkit authentication framework for privilege escalation dialogs
  services.gnome.gnome-keyring.enable = true; # Secret Service provider for storing user credentials and keys

  # ----- Systemd Integration -----
  systemd.user.services.niri.enableDefaultPath = false; # Prevent systemd from overriding Niri's session PATH environment
}
