_: {
  programs.firefox.policies = {
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
    OfferToSaveLogins = false;

    PopupBlocking.Default = true;
    HttpsOnlyMode = "force_enabled";
    PostQuantumKeyAgreementEnabled = true;

    BlockAboutConfig = true;
    BlockAboutProfiles = false;
    BlockAboutSupport = false;

    DNSOverHTTPS = {
      Enabled = true;
      ProviderURL = "https://wurzn.hagezi.org/dns-query";
      Fallback = false;
    };

    EnableTrackingProtection = {
      Category = "strict";
      BaselineExceptions = true;
      ConvenienceExceptions = true;
    };
  };
}
