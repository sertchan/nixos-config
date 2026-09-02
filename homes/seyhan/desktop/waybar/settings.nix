_: {
  programs.waybar.settings.mainBar = {
    # ----- Bar Layout & Module Alignment -----
    layer = "bottom";
    position = "top";
    "fixed-center" = true;
    height = 34;
    spacing = 0;
    "margin-top" = 4;
    "margin-left" = 6;
    "margin-right" = 6;

    "modules-left" = [
      "niri/workspaces"
    ];

    "modules-center" = [
    ];

    "modules-right" = [
      "group/connectivity"
      "group/system"
      "group/io"
      "group/time"
    ];

    # ----- Module Groups -----
    "group/connectivity" = {
      orientation = "horizontal";
      modules = [
        "tray"
        "network#2"
        "network"
        "bluetooth"
      ];
    };
    "group/system" = {
      orientation = "horizontal";
      modules = [
        "temperature"
        "cpu"
        "memory"
      ];
    };
    "group/io" = {
      orientation = "horizontal";
      modules = [
        "niri/language"
        "wireplumber"
      ];
    };
    "group/time" = {
      orientation = "horizontal";
      modules = [
        "clock"
        "clock#2"
      ];
    };

    # ----- Module Configurations -----
    "niri/workspaces" = {
      "on-click" = "activate";
      format = "{icon}";
      "format-icons" = {
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
        "default" = "{value}";
      };
    };
    "niri/window" = {
      format = "{}";
      "max-length" = 360;
    };
    clock = {
      interval = 1;
      format = "{:%d/%m/%Y}";
    };
    "clock#2" = {
      interval = 1;
      format = "{:%H:%M}";
    };
    bluetooth = {
      tooltip = false;
      "format-connected" = "󰂯 {device_alias}";
      "format-on" = "";
      "format-off" = "";
      "format-disabled" = "";
      "format-no-controller" = "";
    };
    wireplumber = {
      tooltip = false;
      format = "{icon}  {volume}%";
      "format-muted" = "  Muted";
      "format-icons" = [
        ""
        ""
        ""
      ];
    };
    tray = {
      tooltip = false;
      "icon-size" = 14;
      spacing = 10;
    };
    cpu = {
      interval = 1;
      tooltip = false;
      format = "  {usage}%";
      states = {
        warning = 70;
        critical = 90;
      };
    };
    memory = {
      interval = 1;
      format = "  {used:0.1f}G";
    };
    network = {
      interval = 1;
      interface = "wlp0s20f3"; # Wireless Wi-Fi interface
      format = "{icon}  {essid}";
      "format-linked" = "󰤩  Connecting";
      "format-disconnected" = "";
      "format-icons" = [
        "󰤯"
        "󰤟"
        "󰤢"
        "󰤥"
        "󰤨"
      ];
      tooltip = false;
    };
    "network#2" = {
      interval = 1;
      interface = "enp6s0"; # Wired Ethernet interface
      format = "󰈀  Connected";
      "format-linked" = "󰈀  Connecting";
      "format-disconnected" = "";
      tooltip = false;
    };
    temperature = {
      interval = 1;
      "hwmon-path" = "/sys/class/hwmon/hwmon4/temp1_input"; # Linux sysfs hardware monitor temperature sensor path
      tooltip = false;
      "warning-threshold" = 70;
      "critical-threshold" = 90;
      format = "󰏈  {temperatureC}°C";
    };
    "niri/language" = {
      format = "  {}";
      "format-en" = "EN";
      "format-tr" = "TR";
    };
  };
}
