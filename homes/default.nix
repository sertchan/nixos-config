{ pkgs, ... }: {
  home-manager = {
    verbose = true;
    useGlobalPkgs = true; # Use system-level nixpkgs instance instead of private evaluation
    useUserPackages = true; # Install packages to system user profile instead of ~/.nix-profile
    backupFileExtension = "backup"; # Automatically rename conflicting unmanaged files with .backup extension
    extraSpecialArgs = { inherit pkgs; }; # Forward pkgs parameter to user-level configuration modules
    users = {
      "seyhan" = ./seyhan;
    };
  };
}
