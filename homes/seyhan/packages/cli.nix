{pkgs, ...}: {
  home.packages = with pkgs; [
    android-tools
    bc
    claude-code
    dust
    geekbench
    inotify-tools
    just
    openssl
    p7zip
    psmisc
    tree
    unzip
    zip
  ];
}
