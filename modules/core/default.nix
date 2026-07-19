{
  imports = [
    # --- System Boot & Network ---
    ./boot.nix
    ./networking.nix

    # --- NixOS Settings ---
    ./nix-settings.nix

    # --- Users, Packages & Shell ---
    ./packages.nix
    ./shell.nix
    ./users.nix
  ];
}
