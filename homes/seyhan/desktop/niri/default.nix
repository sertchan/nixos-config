{
  imports = [
    ./scripts.nix
  ];

  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
