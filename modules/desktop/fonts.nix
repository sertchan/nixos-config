{ pkgs, ... }: {
  fonts = {
    # ----- Fontconfig Settings -----
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
          "Literata"
          "Noto Serif"
        ];
        sansSerif = [
          "Adwaita Sans"
          "Noto Sans"
        ];
        monospace = [
          "Adwaita Mono"
          "Noto Sans Mono"
        ];
        emoji = [
          "Noto Color Emoji"
        ];
      };
    };

    # ----- Installed Fonts -----
    packages = with pkgs; [
      literata
      adwaita-fonts
      nerd-fonts.jetbrains-mono

      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans # Chinese, Japanese, and Korean sans-serif fonts
      noto-fonts-cjk-serif # Chinese, Japanese, and Korean serif fonts
    ];
  };
}
