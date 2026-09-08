{osConfig, ...}: let
  inherit (osConfig.modules.style) gtkColorDefinitions;
in {
  imports = [./settings.nix];

  programs.wofi = {
    enable = true;
    style = gtkColorDefinitions + builtins.readFile ./style.css;
  };
}
