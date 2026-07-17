_: {
  services.mako = {
    enable = true;

    settings = {
      "on-button-left" = "dismiss";
      "on-button-middle" = "none";
      "on-button-right" = "dismiss-all";
      "on-touch" = "dismiss";

      font = "Jetbrains Mono Regular 10";
      width = 400;
      height = 250;
      margin = 4;
      padding = 4;
      "border-size" = 2;
      icons = 1;
      "max-icon-size" = 90;
      "icon-location" = "left";
      markup = 1;
      actions = 1;
      history = 1;
      "text-alignment" = "right";
      "default-timeout" = 5000;
      "ignore-timeout" = 0;
      "max-visible" = 20;
      layer = "overlay";
      anchor = "top-right";

      "background-color" = "#151515";
      "text-color" = "#D0D0D0";
      "border-color" = "#444545";
    };
  };
}
