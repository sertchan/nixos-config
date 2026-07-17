{ pkgs, ... }: {
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      allowBitmaps = false;

      hinting = {
        enable = true;
        style = "slight";
      };

      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
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
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      liberation_ttf
    ];
  };
}
