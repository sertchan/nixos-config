{pkgs, ...}: let
  themeName = "adw-gtk3-dark";
  iconThemeName = "Adwaita";

  toolkitSettings = {
    gtk-decoration-layout = "appmenu:none";
    gtk-enable-event-sounds = 0;
    gtk-enable-input-feedback-sounds = 0;
    gtk-xft-antialias = 1;
    gtk-xft-hinting = 1;
    gtk-xft-hintstyle = "hintslight";
    gtk-xft-rgba = "rgb";
    gtk-error-bell = 0;
    gtk-enable-primary-paste = false;
  };
in {
  gtk = {
    enable = true;
    theme = {
      name = themeName;
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = iconThemeName;
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = "Adwaita Sans";
      size = 11;
    };
    gtk3.extraConfig = toolkitSettings;
    gtk4 = {
      theme = null;
      extraConfig = toolkitSettings // {gtk-hint-font-metrics = 1;};
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = themeName;
    icon-theme = iconThemeName;
  };
}
