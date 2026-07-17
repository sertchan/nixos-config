_: {
  wayland.windowManager.hyprland.settings = {
    # Preferences
    general = {
      layout = "master";
      border_size = 0;
      gaps_in = 4;
      gaps_out = 4;
    };

    #Layout
    master = {
      orientation = "left";
    };

    # Decoration
    decoration = {
      blur = {
        enabled = true;
        size = 10;
        passes = 2;
      };
    };
    animations = {
      enabled = true;
      bezier = "fluent_decel, 0.1, 1, 0, 1";
      animation = [
        "windows, 1, 4, fluent_decel"
        "windowsOut, 1, 4, default"
        "border, 0, 4, default"
        "borderangle, 0, 4, default"
        "fade, 1, 4, default"
        "workspaces, 1, 6, default"
      ];
    };

    windowrule = [
      "match:class org.gnome.Nautilus, float on"
      "match:class org.gnome.Nautilus, size (window_w*1.5) (window_h*1.5)"
      "match:class org.gnome.Loupe, float on"
      "match:class mpv, float on"
      "match:class mpv, size (monitor_w*0.65) (monitor_h*0.65)"
      "match:class xdg-desktop-portal-gtk, size (monitor_w*0.6) (monitor_h*0.75)"
      "match:class xdg-desktop-portal-gtk, center on"
    ];

    layerrule = "blur on, match:namespace waybar";
  };
}
