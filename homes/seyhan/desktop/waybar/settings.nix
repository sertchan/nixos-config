_: {
  programs.waybar.settings.mainBar = {
    # ----- Bar Layout & Module Alignment -----
    layer = "bottom";
    position = "top";
    "fixed-center" = true;

    "modules-left" = [
      "niri/workspaces"
    ];

    "modules-center" = [
      "clock"
      "clock#2"
    ];

    "modules-right" = [
      "tray"
      #"bluetooth"
      "temperature"
      "cpu"
      "memory"
      "network#2"
      "network"
      "wireplumber"
    ];

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
      interval = 60;
      format = "{:%a, %b %d}";
    };
    "clock#2" = {
      interval = 1;
      format = "{:%H:%M}";
    };
    bluetooth = {
      tooltip = false;
      "format-on" = "󰂯";
      "format-connected" = "󰂯";
      "format-off" = "󰂲 Down";
      "format-disabled" = "󰂲 Disabled";
    };
    wireplumber = {
      tooltip = false;
      format = "  {volume}%";
      "format-muted" = "  Muted";
    };
    tray = {
      tooltip = false;
      "icon-size" = 15;
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
      format = "󰤨  {essid}";
      "format-linked" = "󰤩  Connecting";
      "format-disconnected" = "";
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
  };
}
