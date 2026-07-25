{
  config,
  pkgs,
  lib,
  ...
}:
{
  nix = {
    settings = {
      use-xdg-base-directories = true; # Store Nix user files according to XDG spec (~/.config/nix, ~/.local/state/nix)
      flake-registry = "/etc/nix/registry.json";
      warn-dirty = false; # Disable warnings about uncommitted Git files when evaluating flakes
      accept-flake-config = false; # Ignore custom nix.conf settings exported by external flakes

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

      trusted-users = [
        "root"
      ]; # Users with elevated daemon privileges (e.g., overriding binary caches)

      sandbox = true;
      sandbox-fallback = false; # Fail build immediately if sandboxing is unavailable
      max-jobs = "auto"; # Scale maximum parallel build processes to CPU core count
      system-features = [
        "nixos-test"
        "kvm"
        "recursive-nix"
        "big-parallel"
      ];
      extra-platforms = config.boot.binfmt.emulatedSystems; # Architectures supported via binfmt emulation

      connect-timeout = 5;
      http-connections = 50;
      log-lines = 30; # Number of build log lines to retain and print on failure
      keep-going = true; # Continue building independent derivations if one fails
      builders-use-substitutes = true; # Permit remote builders to fetch pre-built outputs from binary caches

      min-free = toString (5 * 1024 * 1024 * 1024); # Trigger GC if free disk space falls below 5 GiB
      max-free = toString (10 * 1024 * 1024 * 1024); # Stop GC once free disk space reaches 10 GiB
      auto-optimise-store = false; # Store optimization runs on a separate weekly timer (see nix.optimise below)
      keep-derivations = true; # Retain build derivations to allow offline rebuilds
      keep-outputs = true; # Retain build outputs to prevent GC of shell dependencies

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
      persistent = true; # Execute missed runs immediately on next system boot
      randomizedDelaySec = "30min"; # Randomly delay trigger time up to 30 minutes to prevent resource contention
      dates = "weekly";
    };

    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  # nh: Command-line wrapper for building and switching NixOS configurations
  programs.nh = {
    enable = true;
    package = pkgs.nh;
    flake = lib.mkDefault "${config.users.users.seyhan.home}/.nixos";
  };
}
