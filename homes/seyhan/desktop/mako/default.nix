{osConfig, ...}: let
  inherit (osConfig.modules.style) colors;

  surface = "#0a0a0a";
  criticalSurface = "#140505";
  dimmedText = "#a0a0a0";
in {
  services.mako = {
    enable = true;
    settings = {
      "on-button-left" = "dismiss";
      "on-button-middle" = "none";
      "on-button-right" = "dismiss-all";
      "on-touch" = "dismiss";
      actions = 1;
      anchor = "top-right";
      "default-timeout" = 5000;
      history = 1;
      "ignore-timeout" = 0;
      layer = "overlay";
      "max-visible" = 20;
      "text-alignment" = "left";
      font = "AdwaitaMono Nerd Font 11";
      width = 400;
      height = 250;
      "outer-margin" = "8";
      margin = "0";
      padding = "12,16";
      "border-size" = 1;
      "border-radius" = 0;
      icons = 1;
      "max-icon-size" = 64;
      "icon-location" = "left";
      "icon-border-radius" = 0;
      markup = 1;
      "background-color" = "${surface}e6";
      "text-color" = colors.foreground;
      "border-color" = "${colors.foreground}26";
      "progress-color" = "over ${colors.good}cc";
    };

    extraConfig = ''
      [urgency=low]
      background-color=${surface}b3
      text-color=${dimmedText}
      border-color=${colors.foreground}1a
      progress-color=over ${colors.warning}88

      [urgency=normal]
      background-color=${surface}e6
      text-color=${colors.foreground}
      border-color=${colors.foreground}26
      progress-color=over ${colors.good}cc

      [urgency=critical]
      background-color=${criticalSurface}e6
      text-color=${colors.foreground}
      border-color=${colors.critical}cc
      progress-color=over ${colors.critical}ff
    '';
  };
}
