{
  config,
  lib,
  ...
}:
{
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox"; # Store Firefox profile in XDG config directory

    policies = {
      # ----- Updates & Background Services -----
      AppAutoUpdate = false;

      # ----- Feature Disabling -----
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

      # ----- Popup Blocking -----
      PopupBlocking.Default = true;

      # ----- Disable AI Related Features -----
      AIControls.Default = {
        Value = "blocked";
        Locked = true;
      };
      GenerativeAI.Enabled = false;

      # ----- Encrypted Media Extensions -----
      EncryptedMediaExtensions.Enabled = true;

      # ----- DNS-over-HTTPS -----
      DNSOverHTTPS = {
        Enabled = true;
        ProviderURL = "https://wurzn.hagezi.org/dns-query";
        Fallback = false;
      };

      # ----- Https Only Mode -----
      HttpsOnlyMode = "force_enabled";

      # ----- Tracking Protection -----
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

      # ----- Post-Quantum key agreement for TLS -----
      PostQuantumKeyAgreementEnabled = true;

      # ----- Disable Website Translation -----
      TranslateEnabled = false;

      # ----- Access Restrictions -----
      BlockAboutConfig = true;
      BlockAboutProfiles = false;
      BlockAboutSupport = false;

      # ----- UI and Behavior -----
      DisplayMenuBar = "never";
      DontCheckDefaultBrowser = true;
      HardwareAcceleration = true;
      OfferToSaveLogins = false;
      DefaultDownloadDirectory = "${config.xdg.configHome}/Downloads";

      # ----- Extensions -----
      ExtensionSettings =
        let
          moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
        in
        {
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

          "foto-bold-colorway@mozilla.org" = {
            install_url = moz "foto-bold";
            installation_mode = "force_installed";
            updates_disabled = true;
          };
        };

      # ----- Extension configuration -----
      "3rdparty".Extensions = {
        "uBlock0@raymondhill.net".adminSettings = {
          userSettings = {
            uiTheme = "dark";
            cloudStorageEnabled = lib.mkForce false;
          };

          selectedFilterLists = [
            # ----- Built-in -----
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"

            # ----- Ads -----
            "easylist"

            # ----- Privacy -----
            "easyprivacy"
            "adguard-spyware-url"

            # ----- Cookie notices -----
            "adguard-cookies"
            "ublock-cookies-adguard"

            # ----- Annoyances -----
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

            # ----- Regions, languages -----
            "TUR-0"
          ];
        };
      };
    };
  };
}
