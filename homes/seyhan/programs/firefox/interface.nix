_: {
  programs.firefox.policies = {
    DisplayBookmarksToolbar = "never";
    DisplayMenuBar = "never";
    NoDefaultBookmarks = true;
    FirefoxHome.TopSites = false;
    TranslateEnabled = false;

    Preferences."media.videocontrols.picture-in-picture.video-toggle.enabled" = {
      Value = false;
      Status = "default";
    };
  };
}
