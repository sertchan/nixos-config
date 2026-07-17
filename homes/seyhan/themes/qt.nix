{ pkgs, ... }: {
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt;
  };
}
