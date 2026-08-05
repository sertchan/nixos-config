{ pkgs, ... }:
let
  username = "seyhan";
in
{
  imports = [
    ./desktop
    ./programs
    ./themes
  ];

  config = {
    home = {
      inherit username;
      homeDirectory = "/home/${username}";

      stateVersion = "24.11";

      packages = with pkgs; [
        libnotify
        easyeffects
        awww
        onlyoffice-desktopeditors
        bc
        bluez
        bluez-tools
        btop
        claude-code
        codex
        vesktop
        dragon-drop
        dust
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
        loupe
        mako
        mpv
        nautilus
        nitch
        nixfmt
        obsidian
        p7zip
        openssl
        pinentry-curses
        prismlauncher
        psmisc
        pulsemixer
        qbittorrent
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

    programs = {
      gh.enable = true;
      git.enable = true;
      gpg.enable = true;
      home-manager.enable = true;

      neovim = {
        enable = true;
        withRuby = false;
        withPython3 = false;

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
          vim.g.mapleader = " "
          vim.g.maplocalleader = " "

          vim.g.loaded_node_provider = 0
          vim.g.loaded_perl_provider = 0
          vim.g.loaded_ruby_provider = 0
          vim.g.loaded_python3_provider = 0

          require("core.options")
          require("core.keymaps")

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
