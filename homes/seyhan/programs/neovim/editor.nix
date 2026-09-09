_: {
  programs.neovim = {
    enable = true;
    withPython3 = false;
    withRuby = false;
    initLua = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      require("config.filetypes")
      require("config.options")
      require("config.keymaps")
      require("config.diagnostics")
      require("config.restore-cursor")
      require("config.treesitter")
      require("config.lsp")
      require("config.highlights")

      require("plugins.kanagawa")
      require("plugins.lualine")
      require("plugins.nvim-tree")
      require("plugins.blink-cmp")
      require("plugins.conform")
      require("plugins.nvim-lint")
      require("plugins.fzf-lua")
      require("plugins.gitsigns")
      require("plugins.indent-blankline")
      require("plugins.mini-pairs")
      require("plugins.mini-surround")
    '';
  };

  xdg.configFile."nvim/lsp".source = ./lsp;
}
