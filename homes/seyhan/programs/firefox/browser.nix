{
  config,
  pkgs,
  ...
}: let
  hideFullscreenNotice = ''
    defaultPref("full-screen-api.warning.timeout", 0);
  '';

  setDefaultZoom = ''
    try {
      Components.classes["@mozilla.org/content-pref/service;1"]
        .getService(Components.interfaces.nsIContentPrefService2)
        .setGlobal(
          "browser.content.full-zoom",
          1.1,
          Components.utils.createLoadContext()
        );
    } catch (e) {}
  '';
in {
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    package = pkgs.firefox.override {extraPrefs = hideFullscreenNotice + setDefaultZoom;};

    policies = {
      AppAutoUpdate = false;
      DontCheckDefaultBrowser = true;
      HardwareAcceleration = true;
      EncryptedMediaExtensions.Enabled = true;
      DefaultDownloadDirectory = config.xdg.userDirs.download;
    };
  };
}
