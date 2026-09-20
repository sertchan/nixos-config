_: let
  moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
  ublock = "uBlock0@raymondhill.net";
in {
  programs.firefox.policies = {
    ExtensionSettings = {
      "*".installation_mode = "blocked";

      ${ublock} = {
        install_url = moz "ublock-origin";
        installation_mode = "force_installed";
        updates_disabled = false;
        default_area = "navbar";
        private_browsing = true;
      };

      "sponsorBlocker@ajay.app" = {
        install_url = moz "sponsorblock";
        installation_mode = "force_installed";
        updates_disabled = false;
        default_area = "menupanel";
        private_browsing = true;
      };

      "elemental-bold-colorway@mozilla.org" = {
        install_url = moz "elemental-bold";
        installation_mode = "force_installed";
        updates_disabled = false;
      };
    };

    "3rdparty".Extensions.${ublock}.adminSettings = {
      userSettings = {
        advancedUserEnabled = true;
        uiTheme = "dark";
        cloudStorageEnabled = false;
      };

      selectedFilterLists = [
        "ublock-filters"
        "ublock-badware"
        "ublock-privacy"
        "ublock-quick-fixes"
        "ublock-unbreak"
        "easylist"
        "easyprivacy"
        "adguard-spyware-url"
        "fanboy-cookiemonster"
        "ublock-cookies-easylist"
        "adguard-cookies"
        "ublock-cookies-adguard"
        "fanboy-social"
        "fanboy-thirdparty_social"
        "adguard-social"
        "fanboy-ai-suggestions"
        "easylist-chat"
        "easylist-newsletters"
        "easylist-notifications"
        "easylist-annoyances"
        "adguard-mobile-app-banners"
        "adguard-other-annoyances"
        "adguard-popup-overlays"
        "adguard-widgets"
        "ublock-annoyances"
        "TUR-0"
      ];
    };
  };
}
