{
  config,
  pkgs,
  lib,
  ...
}: {
  nix = {
    settings = {
      use-xdg-base-directories = true;
      flake-registry = "/etc/nix/registry.json";
      warn-dirty = false;
      accept-flake-config = false;
      extra-experimental-features = [
        "flakes"
        "nix-command"
        "recursive-nix"
      ];
      allowed-users = [
        "root"
        "@wheel"
        "nix-builder"
      ];
      trusted-users = ["root"];
      sandbox = true;
      sandbox-fallback = false;
      max-jobs = "auto";
      system-features = [
        "nixos-test"
        "kvm"
        "recursive-nix"
        "big-parallel"
      ];
      extra-platforms = config.boot.binfmt.emulatedSystems;
      connect-timeout = 5;
      http-connections = 50;
      log-lines = 30;
      keep-going = true;
      builders-use-substitutes = true;
      min-free = toString (5 * 1024 * 1024 * 1024);
      max-free = toString (10 * 1024 * 1024 * 1024);
      auto-optimise-store = false;
      keep-derivations = true;
      keep-outputs = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      persistent = true;
      randomizedDelaySec = "30min";
      dates = "weekly";
    };

    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs.nh = {
    enable = true;
    package = pkgs.nh;
    flake = lib.mkDefault "${config.users.users.seyhan.home}/.nixos";
  };
}
