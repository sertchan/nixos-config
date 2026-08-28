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
        android-tools
        awww
        bc
        bluez
        bluez-tools
        brightnessctl
        btop
        claude-code
        codex
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
