_: {
  services.mako = {
    enable = true;

    # ----- Global Configuration Options -----
    settings = {
      # ----- Behavior & Interaction -----
      "on-button-left" = "dismiss";
      "on-button-middle" = "none";
      "on-button-right" = "dismiss-all";
      "on-touch" = "dismiss";

      actions = 1;
      anchor = "top-right";
      "default-timeout" = 5000;
      history = 1;
      "ignore-timeout" = 0;
      layer = "overlay"; # Render notifications above all desktop windows
      "max-visible" = 20;
      "text-alignment" = "left";

      # ----- Typography & Layout -----
      # Monospace bold font matching waybar style (AdwaitaMono Nerd Font)
      font = "AdwaitaMono Nerd Font 11";
      width = 400;
      height = 250;
      # Use outer-margin for screen edge spacing (handled by wlr-layer-shell)
      # and margin = "0" to keep stacked notification cards flush without transparent
      # internal gaps that cause compositor blur to bleed between cards.
      "outer-margin" = "8";
      margin = "0";
      padding = "12,16";
      "border-size" = 1;
      "border-radius" = 0;

      # ----- Icons & Media -----
      icons = 1;
      "max-icon-size" = 64;
      "icon-location" = "left";
      "icon-border-radius" = 0;
      markup = 1;

      # ----- Global Visual Style -----
      # Dark backdrop matching waybar (rgba(10, 10, 10, 0.8) -> #0a0a0acc) with white text & waybar accent colors
      "background-color" = "#0a0a0acc";
      "text-color" = "#ffffff";
      "border-color" = "#ffffff26";
      "progress-color" = "over #00ff00cc";
    };

    # ----- Urgency Criteria Sections -----
    # Mako requires single-bracket criteria syntax [urgency=level]
    # Urgency variants derive from waybar's palette: gray muted text for low, waybar green accent for normal, waybar red for critical
    extraConfig = ''
      [urgency=low]
      background-color=#0a0a0ab3
      text-color=#a0a0a0
      border-color=#ffffff1a
      progress-color=over #ffff0088

      [urgency=normal]
      background-color=#0a0a0acc
      text-color=#ffffff
      border-color=#ffffff26
      progress-color=over #00ff00cc

      [urgency=critical]
      background-color=#140505e6
      text-color=#ffffff
      border-color=#ff0000cc
      progress-color=over #ff0000ff
    '';
  };
}
