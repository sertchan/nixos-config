{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.strings) escapeShellArg;

  user = config.users.users.seyhan;

  importWholeEnvironment = "systemctl --user import-environment";
  importNamedEnvironment = "${importWholeEnvironment} $(awk 'BEGIN{for (name in ENVIRON) if (name != \"AWKPATH\" && name != \"AWKLIBPATH\") print name}')";
in {
  programs.niri = {
    enable = true;
    package = pkgs.niri.overrideAttrs (prev: {
      postInstall =
        prev.postInstall
        + ''
          substituteInPlace $out/bin/niri-session \
            --replace-fail ${escapeShellArg importWholeEnvironment} ${escapeShellArg importNamedEnvironment}
        '';
    });
  };

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
