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
    nvim-lint
    nvim-tree-lua
    nvim-web-devicons
  ];
}
