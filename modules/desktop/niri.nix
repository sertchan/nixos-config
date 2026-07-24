{ pkgs, ... }: {
  programs.niri.enable = true;

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
    xwayland-satellite
  ];
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  systemd.user.services.niri.enableDefaultPath = false;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
