{ pkgs, ... }:
let
  breeze = pkgs.kdePackages.breeze;

  # Color scheme files share kdeglobals' INI format, so Breeze Dark can be used verbatim and extended
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
in
{
  # ----- Qt Configuration -----
  qt = {
    enable = true;

    platformTheme = {
      name = "kde"; # KDE platform theme reads kdeglobals for palette, icons, fonts and dialogs
      # Only the plugin and KIO are needed; skips systemsettings, which pulls in the Plasma workspace
      package = with pkgs.kdePackages; [
        plasma-integration
        kio
      ];
    };

    style = {
      name = "Breeze";
      package = [ breeze ]; # Qt 6 plugin only, add breeze.qt5 alongside it for Qt 5 applications
    };
  };

  # ----- KDE Global Settings -----
  # Read-only symlink, so KDE apps cannot persist their own appearance changes
  xdg.configFile."kdeglobals".source = kdeglobals;

  home.packages = [ pkgs.kdePackages.breeze-icons ];
}
