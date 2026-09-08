{
  osConfig,
  lib,
  ...
}: let
  inherit (lib.strings) removePrefix;

  inherit (osConfig.modules.style) colors;

  terminalFont = "AdwaitaMono Nerd Font";
in {
  programs.ghostty = {
    enable = true;
    settings = {
      background-opacity = 1.00;
      font-size = 12;
      font-family = terminalFont;
      font-family-bold = terminalFont;
      font-family-italic = terminalFont;
      font-family-bold-italic = terminalFont;
      background = removePrefix "#" colors.base;
      foreground = "c5c9c5";
      selection-background = "2d4f67";
      selection-foreground = "c8c093";
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
        "16=#ffa066"
        "17=#ff5d62"
      ];
    };
  };
}
