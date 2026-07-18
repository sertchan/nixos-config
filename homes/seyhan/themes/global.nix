{ pkgs, ... }: {
  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 16;
    gtk.enable = true;
    x11.enable = true;
  };
}
