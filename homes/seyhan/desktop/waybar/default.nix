{osConfig, ...}: let
  inherit (osConfig.modules.style) gtkColorDefinitions;
in {
  imports = [./settings.nix];

  programs.waybar = {
    enable = true;
    style = gtkColorDefinitions + builtins.readFile ./style.css;
  };
}
