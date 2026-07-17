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
    ./themes
    ./desktop
    ./programs
  ];

  config = {
    home = {
      inherit username;
      homeDirectory = "/home/${username}";

      stateVersion = "24.11"; # DONT CHANGE unless you know what you're doing

      packages = with pkgs; [
        glib
        gsettings-desktop-schemas
        keepassxc
        google-chrome
        loupe
        awww
        wev
        bc
        element-desktop
        tree
        bluez
        bluez-tools
        btop
        discord
        dragon-drop
        dust
        fastfetch
        ffmpeg_7-full
        ffmpegthumbnailer
        ffsubsync
        geekbench
        grimblast
        imagemagick
        inotify-tools
        isort
        jq
        just
        mako
        mpv
        nitch
        nautilus
        nixfmt
        p7zip
        pinentry-curses
        psmisc
        pulsemixer
        qbittorrent-nox
        ranger
        spotify
        ueberzugpp
        unzip
        waifu2x-converter-cpp
        wofi
        xdg-utils
        xdotool
        yt-dlp
        zip
      ];
    };

    programs = {
      home-manager.enable = true;
      git.enable = true;
      gpg.enable = true;
      gh.enable = true;

      firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
      };

      neovim = {
        enable = true;
        withRuby = false;
        withPython3 = false;

        # Formatters/linters exposed to neovim via $PATH
        extraPackages = with pkgs; [
          stylua
          lua51Packages.luacheck
          lua51Packages.tree-sitter-cli
          vale
          beautysh
          taplo
          rustfmt
          prettierd
          deadnix
          statix
          alejandra
          nixfmt
          nixpkgs-fmt
          fixjson
          gcc
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
