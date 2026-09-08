_: {
  home-manager = {
    verbose = true;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users = {"seyhan" = ./seyhan;};
  };
}
