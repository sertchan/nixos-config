{
  pkgs,
  config,
  ...
}:
let
  username = "seyhan"; # Change this to reuse the config for another user
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

      stateVersion = "24.11"; # DONT CHANGE unless you know what you're doing

      packages = with pkgs; [
        antigravity-cli
        awww
        prismlauncher
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

    programs = {
      firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
      };

      gh.enable = true;
      git.enable = true;
      gpg.enable = true;
      home-manager.enable = true;

      neovim = {
        enable = true;
        withRuby = false;
        withPython3 = false;

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
          -- General config
          require('core.keybinds')
          require('core.options')

          -- Plugins
          require('core.plugins')
          require('core.plugin_config')
        '';
      };
    };
  };
}
