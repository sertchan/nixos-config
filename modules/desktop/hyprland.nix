{ pkgs, ... }: {
  programs.hyprland.enable = true;

  # Auto-login to Hyprland on startup
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "start-hyprland";
        user = "seyhan";
      };
      default_session = initial_session;
    };
  };

  security.polkit.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Force Electron/Chromium apps to use Wayland natively

  # Gnome Polkit agent for privilege escalation prompts
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    enable = true;
    description = "Polkit authentication agent of Gnome";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 10;
    };
  };
}
