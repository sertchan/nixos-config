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

      # Disk space thresholds for automatic GC
      min-free = toString (5 * 1024 * 1024 * 1024); # 5 GiB
      max-free = toString (10 * 1024 * 1024 * 1024); # 10 GiB

      # Store optimisation runs on its own weekly timer instead (see nix.optimise below)
      auto-optimise-store = false;

      # Users allowed to run nix commands / use the daemon.
      allowed-users = [
        "root"
        "@wheel"
        "nix-builder"
      ];

      # Users allowed to bypass sandboxing and override daemon settings. Root only
      trusted-users = [
        "root"
      ];

      max-jobs = "auto";

      sandbox = true;
      sandbox-fallback = false; # fail build instead of silently running unsandboxed

      # System features supported by the build machine
      system-features = [
        "nixos-test"
        "kvm"
        "recursive-nix"
        "big-parallel"
      ];
      extra-platforms = config.boot.binfmt.emulatedSystems; # Emulated architectures via binfmt_misc

      keep-going = true;
      connect-timeout = 5;
      log-lines = 30;

      # Experimental Nix features to enable
      extra-experimental-features = [
        "flakes"
        "nix-command"
        "recursive-nix"
      ];

      warn-dirty = false; # Disable warnings about dirty Git repositories when using flakes
      http-connections = 50;
      accept-flake-config = false; # ignore nix.conf settings suggested by flakes
      keep-derivations = true; # Keep build-time dependencies (enables offline rebuilds)
      keep-outputs = true; # Keep build outputs (prevents GC from removing run-time requirements of dev shells)
      builders-use-substitutes = true; # Permit remote builders to download from caches

      # Binary caches. Official cache only
      substituters = [
        "https://cache.nixos.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };

    # Weekly garbage collection
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      persistent = true; # Run instantly on next boot if a scheduled run was missed
      randomizedDelaySec = "30min"; # Delay execution randomly by up to 30 mins to avoid CPU spikes
      dates = "weekly";
    };

    # Weekly store optimisation (hardlinking identical files)
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

  # nh: CLI wrapper for building/switching nix generations
  programs.nh = {
    enable = true;
    package = pkgs.nh;
    flake = lib.mkDefault "${config.users.users.seyhan.home}/.nixos";
  };
}
