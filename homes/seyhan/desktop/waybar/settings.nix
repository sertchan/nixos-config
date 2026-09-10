{
  osConfig,
  lib,
  ...
}: let
  inherit (lib.lists) optionals;

  dev = osConfig.modules.device;
  sys = osConfig.modules.system;

  pollingInterval = 1;
  horizontalMargin = 6;

  horizontalGroup = modules: {
    orientation = "horizontal";
    inherit modules;
  };

  networkDefaults = {
    interval = pollingInterval;
    format-disconnected = "";
    tooltip = false;
  };
in {
  programs.waybar = {
    enable = true;

    settings.mainBar = {
      layer = "bottom";
      position = "top";
      fixed-center = true;
      height = 34;
      spacing = 0;
      margin-top = 4;
      margin-left = horizontalMargin;
      margin-right = horizontalMargin;

      modules-left = [
        "niri/workspaces"
        "niri/window"
      ];
      modules-center = [];
      modules-right = [
        "group/connectivity"
        "group/system"
        "group/io"
        "group/time"
      ];

      "niri/workspaces" = {
        on-click = "activate";
        format = "{icon}";
        format-icons = {
          "1" = "I";
          "2" = "II";
          "3" = "III";
          "4" = "IV";
          "5" = "V";
          "6" = "VI";
          "7" = "VII";
          "8" = "VIII";
          "9" = "IX";
          "10" = "X";
          default = "{value}";
        };
      };

      "niri/window" = {
        format = "{}";
        max-length = 360;
      };

      "group/connectivity" = horizontalGroup (
        [
          "tray"
          "network#2"
          "network"
        ]
        ++ optionals sys.bluetooth.enable ["bluetooth"]
      );

      tray = {
        tooltip = false;
        icon-size = 14;
        spacing = 10;
      };

      "network#2" =
        networkDefaults
        // {
          interface = "enp6s0";
          format = "󰈀  Connected";
          format-linked = "󰈀  Connecting";
        };

      network =
        networkDefaults
        // {
          interface = dev.wirelessInterface;
          format = "{icon}  {essid}";
          format-linked = "󰤩  Connecting";
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
        };

      bluetooth = {
        tooltip = false;
        format-on = "";
        format-connected = "󰂯 {device_alias}";
        format-off = "󰂯 Down";
        format-disabled = "󰂯 Disabled";
      };

      "group/system" = horizontalGroup [
        "temperature"
        "cpu"
        "memory"
      ];

      temperature = {
        interval = pollingInterval;
        hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
        input-filename = "temp1_input";
        tooltip = false;
        warning-threshold = 70;
        critical-threshold = 90;
        format = "󰏈  {temperatureC}°C";
      };

      cpu = {
        interval = pollingInterval;
        tooltip = false;
        format = "  {usage}%";
        states = {
          warning = 70;
          critical = 90;
        };
      };

      memory = {
        interval = pollingInterval;
        format = "  {used:0.1f}G";
      };

      "group/io" = horizontalGroup [
        "niri/language"
        "wireplumber"
      ];

      "niri/language" = {
        format = "  {}";
        format-en = "EN";
        format-tr = "TR";
      };

      wireplumber = {
        tooltip = false;
        format = "{icon}  {volume}%";
        format-muted = "  Muted";
        format-icons = [
          ""
          ""
          ""
        ];
      };

      "group/time" = horizontalGroup [
        "clock"
        "clock#2"
      ];

      clock.format = "{:%d/%m/%Y}";
      "clock#2".format = "{:%H:%M}";
    };
  };
}
