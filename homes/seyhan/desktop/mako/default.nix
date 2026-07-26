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
      "text-alignment" = "right";

      # ----- Typography & Layout -----
      font = "Adwaita Sans 10";
      width = 400;
      height = 250;
      margin = "8";
      padding = "12,16";
      "border-size" = 1;
      "border-radius" = 10;

      # ----- Icons & Media -----
      icons = 1;
      "max-icon-size" = 64;
      "icon-location" = "left";
      "icon-border-radius" = 8;
      markup = 1;

      # ----- Global Visual Style -----
      # Semi-transparent dark slate backdrop (~88% opacity) for a modern elevated look with high contrast text
      "background-color" = "#18181be0";
      "text-color" = "#f0f0f0";
      "border-color" = "#ffffff26";
      "progress-color" = "over #7fb4ca88";
    };

    # ----- Urgency Criteria Sections -----
    # Mako requires single-bracket criteria syntax [urgency=level]
    extraConfig = ''
      [urgency=low]
      background-color=#141418d8
      text-color=#a6a69c
      border-color=#8ba4b040

      [urgency=normal]
      background-color=#18181be0
      text-color=#f0f0f0
      border-color=#ffffff26

      [urgency=critical]
      background-color=#221416f0
      text-color=#ffffff
      border-color=#e46876a0
      progress-color=over #e46876ff
    '';
  };
}
