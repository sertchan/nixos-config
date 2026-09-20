{pkgs, ...}: let
  wofiToggle = pkgs.writeShellApplication {
    name = "wofi-toggle";
    runtimeInputs = [
      pkgs.wofi
      pkgs.procps
    ];
    text = ''
      if pgrep -x "wofi" > /dev/null; then
        pkill -x "wofi" || true
      fi
      wofi --show drun
    '';
  };
in {
  home.packages = [wofiToggle];
}
