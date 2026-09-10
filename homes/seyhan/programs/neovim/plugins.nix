{pkgs, ...}: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    blink-cmp
    conform-nvim
    fzf-lua
    gitsigns-nvim
    indent-blankline-nvim
    kanagawa-nvim
    lualine-nvim
    mini-pairs
    mini-surround
    {
      plugin = nvim-lint;
      type = "lua";
      config = ''
        local lint = require("lint")

        lint.linters["markdownlint-cli2"] = require("lint.util").wrap(lint.linters["markdownlint-cli2"], function(diagnostic)
          if not diagnostic.message:match("^error MD013/") then
            return diagnostic
          end
        end)
      '';
    }
    nvim-tree-lua
    nvim-web-devicons
  ];
}
