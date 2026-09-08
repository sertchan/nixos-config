{pkgs, ...}: {
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-qt;
    defaultCacheTtl = 3600;
    maxCacheTtl = 7200;
  };
}
