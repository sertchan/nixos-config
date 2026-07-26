{
  imports = [
    ./scripts.nix
  ];

  xdg.configFile."niri".source = ./config;
}
