{pkgs, ...}: let
  breeze = pkgs.kdePackages.breeze;

  qtFont = family: size: "${family},${toString size},-1,5,50,0,0,0,0,0";
  interfaceFont = qtFont "Adwaita Sans" 11;

  kdeglobals = pkgs.concatText "kdeglobals" [
    "${breeze}/share/color-schemes/BreezeDark.colors"
    (pkgs.writeText "kdeglobals-extra" ''

      [KDE]
      widgetStyle=Breeze

      [Icons]
      Theme=breeze-dark

      [General]
      font=${interfaceFont}
      menuFont=${interfaceFont}
      toolBarFont=${interfaceFont}
      smallestReadableFont=${qtFont "Adwaita Sans" 9}
      fixed=${qtFont "Adwaita Mono" 11}
    '')
  ];
in {
  qt = {
    enable = true;
    platformTheme = {
      name = "kde";
      package = with pkgs.kdePackages; [
        plasma-integration
        kio
      ];
    };
    style = {
      name = "Breeze";
      package = [breeze];
    };
  };

  xdg.configFile."kdeglobals".source = kdeglobals;

  home.packages = [pkgs.kdePackages.breeze-icons];
}
