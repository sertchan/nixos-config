{ ... }:
{
  imports = [
    ./settings.nix
  ];

  programs.wofi = {
    enable = true;
    style = builtins.readFile ./style.css;
  };
}
