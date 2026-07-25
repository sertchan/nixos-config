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
          lua-language-server
          pyright
          rust-analyzer
          nil
          clang-tools
          bash-language-server
          vscode-langservers-extracted
          typescript-language-server
          marksman
          taplo
          yamlfix
          alejandra
          beautysh
          deadnix
          fixjson
          gcc
          isort
          black
          lua51Packages.luacheck
          lua51Packages.tree-sitter-cli
          kdlfmt
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
          -- Set leader keys before loading keymaps or plugins
          vim.g.mapleader = " "
          vim.g.maplocalleader = " "

          -- Disable unused provider plugins to eliminate startup delays from provider detection
          vim.g.loaded_node_provider = 0
          vim.g.loaded_perl_provider = 0
          vim.g.loaded_ruby_provider = 0
          vim.g.loaded_python3_provider = 0

          -- Load native editor settings and keybindings
          require("core.options")
          require("core.keymaps")

          -- Load plugin configurations
          require("plugins.theme")
          require("plugins.ui")
          require("plugins.treesitter")
          require("plugins.explorer")
          require("plugins.formatting")
          require("plugins.linting")
          require("plugins.completion")
          require("plugins.lsp")
          require("plugins.utils")
        '';
      };
    };
  };
}
