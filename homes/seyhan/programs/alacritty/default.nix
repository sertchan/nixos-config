_: {
  programs.alacritty = {
    enable = true;

    settings = {
      window.opacity = 0.90;

      font = {
        size = 10;

        normal = {
          family = "Jetbrains Mono NF";
          style = "Regular";
        };

        bold = {
          family = "Jetbrains Mono NF";
          style = "Bold";
        };

        italic = {
          family = "Jetbrains Mono NF";
          style = "Italic";
        };

        bold_italic = {
          family = "Jetbrains Mono NF";
          style = "Bold Italic";
        };
      };

      colors = {
        primary = {
          background = "#0a0a0a";
          foreground = "#c5c9c5";
        };

        normal = {
          black = "#0c0b0b";
          red = "#c4746e";
          green = "#8a9a7b";
          yellow = "#c4b28a";
          blue = "#8ba4b0";
          magenta = "#a292a3";
          cyan = "#8ea4a2";
          white = "#C8C093";
        };

        bright = {
          black = "#a6a69c";
          red = "#E46876";
          green = "#87a987";
          yellow = "#E6C384";
          blue = "#7FB4CA";
          magenta = "#938AA9";
          cyan = "#7AA89F";
          white = "#c5c9c5";
        };

        selection = {
          background = "#2d4f67";
          foreground = "#c8c093";
        };

        indexed_colors = [
          {
            index = 16;
            color = "#ffa066";
          }
          {
            index = 17;
            color = "#ff5d62";
          }
        ];
      };
    };
  };
}
