_: let
  darkAppearance = 1;
  builtinDarkTheme = "firefox-compact-dark@mozilla.org";
in {
  programs.firefox.policies = {
    DisplayBookmarksToolbar = "never";
    DisplayMenuBar = "never";
    NoDefaultBookmarks = true;
    FirefoxHome.TopSites = false;
    TranslateEnabled = false;

    Preferences = {
      "media.videocontrols.picture-in-picture.video-toggle.enabled" = {
        Value = false;
        Status = "default";
      };

      "ui.systemUsesDarkTheme" = {
        Value = darkAppearance;
        Type = "number";
        Status = "user";
      };

      "extensions.activeThemeID" = {
        Value = builtinDarkTheme;
        Status = "user";
      };
    };
  };
}
