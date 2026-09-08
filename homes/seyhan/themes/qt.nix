{pkgs, ...}: let
  breeze = pkgs.kdePackages.breeze;
  kdeglobals = pkgs.concatText "kdeglobals" [
    "${breeze}/share/color-schemes/BreezeDark.colors"
    (pkgs.writeText "kdeglobals-extra" ''

      [KDE]
      widgetStyle=Breeze

      [Icons]
      Theme=breeze-dark

      [General]
      font=Adwaita Sans,11,-1,5,50,0,0,0,0,0
      menuFont=Adwaita Sans,11,-1,5,50,0,0,0,0,0
      toolBarFont=Adwaita Sans,11,-1,5,50,0,0,0,0,0
      smallestReadableFont=Adwaita Sans,9,-1,5,50,0,0,0,0,0
      fixed=Adwaita Mono,11,-1,5,50,0,0,0,0,0
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
