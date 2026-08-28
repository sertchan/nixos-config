{ pkgs, ... }:
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
        android-tools
        awww
        bc
        bluez
        bluez-tools
        brightnessctl
        btop
        claude-code
        dragon-drop
        dust
        easyeffects
        fastfetch
        ffmpeg_7-full
        ffmpegthumbnailer
        ffsubsync
        geekbench
        glib
        google-chrome
        gsettings-desktop-schemas
        imagemagick
        inotify-tools
        jq
        just
        keepassxc
        libnotify
        loupe
        mako
        mpv
        nautilus
        nitch
        nixfmt
        openssl
        p7zip
        pinentry-curses
        prismlauncher
        psmisc
        pulsemixer
        qbittorrent
        ranger
        spotify
        tor-browser
        tree
        ueberzugpp
        unzip
        vesktop
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
          bash-language-server
          beautysh
          black
          clang-tools
          deadnix
          fixjson
          gcc
          isort
          kdlfmt
          lua-language-server
          lua51Packages.luacheck
          lua51Packages.tree-sitter-cli
          marksman
          nil
          nixfmt
          nixpkgs-fmt
          prettierd
          pyright
          rust-analyzer
          rustfmt
          statix
          stylua
          taplo
          taplo
          typescript-language-server
          vale
          vscode-langservers-extracted
          yamlfix
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
