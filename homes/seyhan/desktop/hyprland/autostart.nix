_: {
  wayland.windowManager.hyprland.settings."exec-once" = [
    "dbus-update-activation-environment --systemd --all"

    "waybar"

    "wallpaper-daemon &"

    "discord --start-minimized &"
  ];
}
