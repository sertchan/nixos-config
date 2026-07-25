{
  pkgs,
  config,
  ...
}:
let
  username = "seyhan"; # Change this to reuse the config for another user
in
{
  # ----- Module Imports -----
  imports = [
    ./desktop
    ./programs
    ./themes
  ];

  # ----- User Environment & Packages -----
  config = {
    home = {
      inherit username;
      homeDirectory = "/home/${username}";

      stateVersion = "24.11"; # State version compatibility for Home Manager

      packages = with pkgs; [
        antigravity-cli
        awww
        bc
        bluez
        bluez-tools
        btop
        claude-code
        discord
        dragon-drop
        dust
        fastfetch
        ffmpeg_7-full
        ffmpegthumbnailer
        ffsubsync
        geekbench
        glib
        google-chrome
        grimblast
        gsettings-desktop-schemas
        imagemagick
        inotify-tools
        isort
        jq
        just
        keepassxc
        loupe
        mako
        mpv
        nautilus
        nitch
        nixfmt
        p7zip
        pinentry-curses
        prismlauncher
        psmisc
        pulsemixer
        qbittorrent-nox
        ranger
        spotify
        tree
        ueberzugpp
        unzip
        waifu2x-converter-cpp
        wev
        wofi
        xdg-utils
        xdotool
        yt-dlp
        zip
      ];
    };

    # ----- User Applications & Tools -----
    programs = {
      firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox"; # Store Firefox profile in XDG config directory
      };

      gh.enable = true;
      git.enable = true;
      gpg.enable = true;
      home-manager.enable = true;

      neovim = {
        enable = true;
        withRuby = false; # Disable Ruby host provider plugin for faster startup
        withPython3 = false; # Disable Python 3 host provider plugin for faster startup

        # Formatters/linters exposed to neovim via $PATH
        extraPackages = with pkgs; [
          alejandra
          beautysh
          deadnix
          fixjson
          gcc
          lua51Packages.luacheck
          lua51Packages.tree-sitter-cli
          nixfmt
          nixpkgs-fmt
          prettierd
          rustfmt
          statix
          stylua
          taplo
          vale
        ];

        initLua = ''
          -- Disable unnecessary provider plugins for faster startup time
          vim.g.loaded_node_provider = 0
          vim.g.loaded_perl_provider = 0
          vim.g.loaded_ruby_provider = 0
          vim.g.loaded_python3_provider = 0

          -- Load core settings and keybindings
          require("core.keybinds")
          require("core.options")

          -- Load plugin configurations
          require("core.plugin_config")
        '';
      };
    };
  };
}
