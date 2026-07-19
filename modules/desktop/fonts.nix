{ pkgs, ... }: {
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      allowBitmaps = false; # Force vector rendering, avoids ugly bitmaps on HiDPI

      hinting = {
        enable = true;
        style = "slight"; # Preserves font shape while snapping vertically to pixel grid
      };

      subpixel = {
        rgba = "rgb";          # Standard LCD subpixel layout
        lcdfilter = "default"; # Reduces color fringing from subpixel rendering
      };

      defaultFonts = {
        serif = [
          "Noto Serif"
          "Liberation Serif"
        ];
        sansSerif = [
          "Noto Sans"
          "Liberation Sans"
        ];
        monospace = [
          "Noto Sans Mono"
          "Liberation Mono"
        ];
        emoji = [
          "Noto Color Emoji"
        ];
      };
    };

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans  # Chinese, Japanese, Korean
      noto-fonts-cjk-serif
      liberation_ttf
    ];
  };
}
