_: {
  programs.git = {
    enable = true;

    settings.user = {
      name = "sertchan";
      email = "ardaseyhan@proton.me";
    };

    signing = {
      key = "74D1EBA78DFCCE3A9E5933A425BB04A414B35B1C";
      signByDefault = true;
    };
  };
}
