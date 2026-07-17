{ pkgs, ... }: {
  # Enable Hyprland
  programs.hyprland.enable = true;

  # For launching Hyprland on login
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
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Polkit authentication agent for such tasks wants root permissions
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
