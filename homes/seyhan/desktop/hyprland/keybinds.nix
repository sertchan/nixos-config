_: {
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";

    bind = [
      # Screenshots
      ", Insert, exec, grimblast --notify copysave area ~/Pictures/Screenshots/$(date \"+%d-%m-%y_%H:%M\").png"
      "Control, Insert, exec, grimblast --notify copysave screen ~/Pictures/Screenshots/$(date \"+%d-%m-%y_%H:%M\").png"

      # Execute apps
      "$mainMod, A, exec, wofi-toggle"
      "$mainMod, Return, exec, alacritty"
      "$mainMod, Z, exec, firefox"
      "$mainMod, X, exec, google-chrome"
      "$mainMod, C, exec, claude-desktop"
      "$mainMod, O, exec, obs"
      "$mainMod, S, exec, spotify"
      "$mainMod, D, exec, discord"
      "$mainMod, F, exec, nautilus"

      # Power management
      "$mainMod ALT, S, exec, systemctl suspend"
      "$mainMod ALT, P, exec, poweroff"
      "$mainMod ALT, R, exec, reboot"

      # Hyprland control
      "$mainMod SHIFT, V, togglefloating"
      "$mainMod SHIFT, C, exec, hyprctl dispatch exit"
      ", F11, fullscreen"
      "$mainMod SHIFT, Q, killactive"

      # Volume - media
      ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
      ", XF86AudioNext, exec, playerctl next"

      # Move focus with mainMod + arrow keys
      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

      # Switch workspaces with mainMod + [0-9]
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"
    ];

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];
  };
}
