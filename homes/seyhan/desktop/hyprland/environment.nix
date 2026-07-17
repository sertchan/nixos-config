_: {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "HDMI-A-1,1920x1080@74.97Hz,auto,1"
      "eDP-1,disable"

    ];

    xwayland = {
      force_zero_scaling = true;
    };

    env = [
      "GDK_BACKEND=wayland,x11"
      "SDL_VIDEODRIVER,wayland"
      "CLUTTER_BACKEND,wayland"
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_TYPE,wayland"
      "XDG_SESSION_DESKTOP,Hyprland"
      "QT_AUTO_SCREEN_SCALE_FACTOR,1"
      "QT_QPA_PLATFORM,wayland;xcb"
      "QT_QPA_PLATFORMTHEME,qt6ct"
    ];

    input = {
      sensitivity = -0.5;
      kb_layout = "us,tr";
      kb_options = "grp:win_space_toggle";
      accel_profile = "flat";
      follow_mouse = 1;
    };
  };
}
