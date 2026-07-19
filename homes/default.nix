{
  pkgs,
  inputs,
  ...
}:
{
  home-manager = {
    verbose = true;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit pkgs inputs; };
    users = {
      "seyhan" = ./seyhan;
    };
  };
}
