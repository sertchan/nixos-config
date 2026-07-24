{ pkgs, ... }:
let
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

  wallpaperDaemon = pkgs.writeShellApplication {
    name = "wallpaper-daemon";
    runtimeInputs = [
      pkgs.awww
      pkgs.findutils
      pkgs.coreutils
    ];
    text = ''
      if ! pgrep -x "awww-daemon" > /dev/null; then
        awww-daemon &
        sleep 0.5
      fi

      WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
      last_wallpaper=""

      while true; do
        if [ -d "$WALLPAPER_DIR" ]; then
          readarray -d ''' wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0)
        else
          echo "Error: Directory $WALLPAPER_DIR not found!" >&2
          sleep 10
          continue
        fi

        if [ ''${#wallpapers[@]} -eq 0 ]; then
          echo "Warning: No suitable images found in the directory." >&2
          sleep 30
          continue
        fi

        while true; do
          current_wallpaper="''${wallpapers[RANDOM % ''${#wallpapers[@]}]}"
          if [ ''${#wallpapers[@]} -eq 1 ] || [ "$current_wallpaper" != "$last_wallpaper" ]; then
            break
          fi
        done

        # "|| true" added so a single failed awww call doesn't kill the whole
        # daemon under writeShellApplication's "set -euo pipefail" — matches
        # the original script's behavior, which just kept looping on failure.
        awww img "$current_wallpaper" -t center --transition-duration 0.7 --transition-fps 75 || true

        last_wallpaper="$current_wallpaper"
        sleep 1h
      done
    '';
  };
in
{
  home.packages = [
    wofiToggle
    wallpaperDaemon
  ];
}
