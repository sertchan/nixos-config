{pkgs, ...}: {
  programs.neovim = {
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
}
