{ pkgs, ... }: {
  home-manager = {
    verbose = true;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit pkgs; };
    users = {
      "seyhan" = ./seyhan;
    };
  };
}
