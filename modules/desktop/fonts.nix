{pkgs, ...}: {
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
        emoji = ["Noto Color Emoji"];
      };
    };

    packages = with pkgs; [
      literata
      adwaita-fonts
      nerd-fonts.adwaita-mono
      corefonts
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
    ];
  };
}
