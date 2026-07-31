{
  xdg.configFile."ghostty/cursor_sweep.glsl".source = ./cursor_sweep.glsl;

  programs.ghostty = {
    enable = true;
    settings = {
      # ----- Window -----
      background-opacity = 1.0;

      # ----- Cursor Shader -----
      custom-shader = "cursor_sweep.glsl";

      # ----- Font -----
      font-size = 12;
      font-family = "AdwaitaMono Nerd Font";
      font-family-bold = "AdwaitaMono Nerd Font";
      font-family-italic = "AdwaitaMono Nerd Font";
      font-family-bold-italic = "AdwaitaMono Nerd Font";

      # ----- Base colors -----
      background = "0f0f0f";
      foreground = "c5c9c5";

      # ----- Selection -----
      selection-background = "2d4f67";
      selection-foreground = "c8c093";

      # ----- 16-color ANSI palette (0-15) -----
      palette = [
        "0=#0c0b0b"
        "1=#c4746e"
        "2=#8a9a7b"
        "3=#c4b28a"
        "4=#8ba4b0"
        "5=#a292a3"
        "6=#8ea4a2"
        "7=#C8C093"
        "8=#a6a69c"
        "9=#E46876"
        "10=#87a987"
        "11=#E6C384"
        "12=#7FB4CA"
        "13=#938AA9"
        "14=#7AA89F"
        "15=#c5c9c5"

        # ----- Extended palette (Kanagawa accents) -----
        "16=#ffa066"
        "17=#ff5d62"
      ];
    };
  };
}
