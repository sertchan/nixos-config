{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkDefault;

  gib = 1024 * 1024 * 1024;
  collectBelow = 5 * gib;
  stopCollectingAt = 10 * gib;
in {
  nix = {
    settings = {
      use-xdg-base-directories = true;
      flake-registry = "/etc/nix/registry.json";
      warn-dirty = false;
      accept-flake-config = false;
      extra-experimental-features = [
        "flakes"
        "nix-command"
      ];
      allowed-users = [
        "root"
        "@wheel"
      ];
      sandbox = true;
      sandbox-fallback = false;
      extra-platforms = config.boot.binfmt.emulatedSystems;
      connect-timeout = 5;
      http-connections = 50;
      log-lines = 30;
      keep-going = true;
      min-free = toString collectBelow;
      max-free = toString stopCollectingAt;
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
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
    flake = mkDefault "${config.users.users.seyhan.home}/.nixos";
  };
}
