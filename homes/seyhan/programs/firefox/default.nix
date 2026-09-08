{config, ...}: {
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    policies = {
      AppAutoUpdate = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxScreenshots = true;
      DisableForgetButton = true;
      DisableMasterPasswordCreation = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisablePocket = true;
      DisableSetDesktopBackground = true;
      DisableTelemetry = true;
      DisableFormHistory = true;
      DisablePasswordReveal = true;
      NoDefaultBookmarks = true;
      OfferToSaveLoginsDefault = false;
      PopupBlocking.Default = true;
      AIControls.Default = {
        Value = "blocked";
        Locked = true;
      };
      GenerativeAI.Enabled = false;
      EncryptedMediaExtensions.Enabled = true;
      DNSOverHTTPS = {
        Enabled = true;
        ProviderURL = "https://wurzn.hagezi.org/dns-query";
        Fallback = false;
      };
      HttpsOnlyMode = "force_enabled";
      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
        SuspectedFingerprinting = true;
        Category = "strict";
        BaselineExceptions = true;
        ConvenienceExceptions = true;
      };
      PostQuantumKeyAgreementEnabled = true;
      TranslateEnabled = false;
      BlockAboutConfig = true;
      BlockAboutProfiles = false;
      BlockAboutSupport = false;
      DisplayMenuBar = "never";
      DontCheckDefaultBrowser = true;
      HardwareAcceleration = true;
      OfferToSaveLogins = false;
      DefaultDownloadDirectory = config.xdg.userDirs.download;
      ExtensionSettings = let
        moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
      in {
        "*".installation_mode = "blocked";
        "uBlock0@raymondhill.net" = {
          install_url = moz "ublock-origin";
          installation_mode = "force_installed";
          updates_disabled = true;
          default_area = "navbar";
          private_browsing = true;
        };
        "sponsorBlocker@ajay.app" = {
          install_url = moz "sponsorblock";
          installation_mode = "force_installed";
          updates_disabled = true;
          default_area = "menupanel";
          private_browsing = true;
        };
        "enhancerforyoutube@maximerf.addons.mozilla.org" = {
          install_url = moz "enhancer-for-youtube";
          installation_mode = "force_installed";
          updates_disabled = true;
          default_area = "menupanel";
          private_browsing = true;
        };
        "elemental-bold-colorway@mozilla.org" = {
          install_url = moz "elemental-bold";
          installation_mode = "force_installed";
          updates_disabled = true;
        };
      };
      "3rdparty".Extensions = {
        "uBlock0@raymondhill.net".adminSettings = {
          userSettings = {
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
    };
  };
}
