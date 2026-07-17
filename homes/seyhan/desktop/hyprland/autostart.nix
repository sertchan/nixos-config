_: {
  wayland.windowManager.hyprland.settings."exec-once" = [
    # Screen sharing
    "dbus-update-activation-environment --systemd --all"

    # Statusbar
    "waybar"

    # Wallpaper
    "wallpaper-daemon &"

    # Discord
    "discord --start-minimized &"
  ];
}
