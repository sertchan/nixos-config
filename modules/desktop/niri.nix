{
  config,
  pkgs,
  ...
}: let
  user = config.users.users.seyhan;
in {
  programs.niri.enable = true;

  environment = {
    systemPackages = with pkgs; [xwayland-satellite];
    loginShellInit = ''
      if [ "$USER" != "root" ] && [ "$(id -u)" -ne 0 ] && [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && { [ "$XDG_VTNR" = "1" ] || [ "$(tty)" = "/dev/tty1" ]; }; then
        exec niri-session -l
      fi
    '';
    sessionVariables = {NIXOS_OZONE_WL = "1";};
  };

  systemd.tmpfiles.settings."screenshots"."${user.home}/Pictures/Screenshots".d = {
    mode = "0700";
    user = user.name;
    group = config.users.groups.${user.group}.name;
  };
}
