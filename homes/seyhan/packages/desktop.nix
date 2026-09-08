{pkgs, ...}: {
  home.packages = with pkgs; [
    awww
    brightnessctl
    glib
    gsettings-desktop-schemas
    keepassxc
    libnotify
    loupe
    nautilus
    playerctl
    prismlauncher
    qbittorrent
    spotify
    tor-browser
    xdg-utils
  ];
}
