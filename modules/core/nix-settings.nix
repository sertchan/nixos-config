{
  config,
  pkgs,
  lib,
  ...
}:
{
  nix = {
    settings = {
      use-xdg-base-directories = true;
      flake-registry = "/etc/nix/registry.json";

      min-free = toString (5 * 1024 * 1024 * 1024);
      max-free = toString (10 * 1024 * 1024 * 1024);

      auto-optimise-store = false;

      allowed-users = [
        "root"
        "@wheel"
        "nix-builder"
      ];

      trusted-users = [
        "root"
      ];

      max-jobs = "auto";

      sandbox = true;
      sandbox-fallback = false;

      system-features = [
        "nixos-test"
        "kvm"
        "recursive-nix"
        "big-parallel"
      ];
      extra-platforms = config.boot.binfmt.emulatedSystems;

      keep-going = true;
      connect-timeout = 5;
      log-lines = 30;

      extra-experimental-features = [
        "flakes"
        "nix-command"
        "recursive-nix"
      ];

      warn-dirty = false;
      http-connections = 50;
      accept-flake-config = false;
      keep-derivations = true;
      keep-outputs = true;
      builders-use-substitutes = true;

      substituters = [
        "https://cache.nixos.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
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
      dates = [ "weekly" ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  programs.nh = {
    enable = true;
    package = pkgs.nh;
    flake = lib.mkDefault "${config.users.users.seyhan.home}/.nixos";
  };
}
