_: {
  programs.waybar.settings.mainBar = {
    layer = "top";
    position = "bottom";
    "fixed-center" = false;

    "modules-left" = [
      "hyprland/workspaces"
      "hyprland/window"
    ];

    "modules-right" = [
      "tray"
      "network#2"
      "network"
      "temperature"
      "cpu"
      "memory"
      "bluetooth"
      "wireplumber"
      #"battery"
      "clock#2"
      "clock"
    ];

    "hyprland/workspaces" = {
      "on-click" = "activate";
    };
    "hyprland/window" = {
      format = "{}";
      "max-length" = 360;
    };
    clock = {
      interval = 60;
      format = "{:%d/%m/%Y}";
    };
    "clock#2" = {
      interval = 1;
      format = "{:%H:%M}";
    };
    disk = {
      interval = 10;
      format = "{path}: {used}/{total}";
      path = "/";
    };
    bluetooth = {
      tooltip = false;
      "format-on" = "";
      "format-connected" = "B: {device_alias}";
      "format-off" = "B: Down";
      "format-disabled" = "B: Disabled";
    };
    wireplumber = {
      tooltip = false;
      format = "V: {volume}%";
      "format-muted" = "V: Muted";
    };
    tray = {
      tooltip = false;
      "icon-size" = 14;
      spacing = 10;
    };
    cpu = {
      interval = 1;
      tooltip = false;
      format = "C: {usage}%";
      states = {
        warning = 70;
        critical = 90;
      };
    };
    memory = {
      interval = 1;
      format = "M: {used:0.1f}G";
    };
    battery = {
      interval = 1;
      bat = "BAT0";
      states = {
        warning = 30;
        critical = 15;
      };
      format = "BAT: {capacity}%";
    };
    network = {
      interval = 1;
      interface = "wlp0s20f3";
      format = "W: {essid}";
      "format-linked" = "W: Connecting";
      "format-disconnected" = "";
      tooltip = false;
    };
    "network#2" = {
      interval = 1;
      interface = "enp6s0";
      format = "E: Connected";
      "format-linked" = "E: Connecting";
      "format-disconnected" = "";
      tooltip = false;
    };
    temperature = {
      interval = 1;
      "hwmon-path" = "/sys/class/hwmon/hwmon4/temp1_input";
      tooltip = false;
      "warning-threshold" = 70;
      "critical-threshold" = 90;
      format = "T: {temperatureC}°C";
    };
  };
}
