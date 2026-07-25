{ pkgs, ... }: {
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      allowBitmaps = false; # Force vector font rendering to prevent blurry bitmap fonts on HiDPI displays

      hinting = {
        enable = true;
        style = "slight"; # Preserves font glyph outlines while aligning vertical stems to pixel grid
      };

      subpixel = {
        rgba = "rgb";
        lcdfilter = "default"; # Reduce color fringing caused by subpixel rendering
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
      noto-fonts-cjk-sans # Chinese, Japanese, and Korean sans-serif fonts
      noto-fonts-cjk-serif # Chinese, Japanese, and Korean serif fonts

      liberation_ttf
    ];
  };
}
