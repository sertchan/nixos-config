{osConfig, ...}: let
  inherit (builtins) readFile;
  inherit (osConfig.modules.style) gtkColorDefinitions;
in {
  programs.waybar.style = gtkColorDefinitions + readFile ./style.css;
}
