{ ... }: {
  imports = [
    ./general.nix
    ./environment.nix
    ./autostart.nix
    ./keybinds.nix
    ./scripts.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    xwayland.enable = true;
    systemd.enable = true;
  };
}
