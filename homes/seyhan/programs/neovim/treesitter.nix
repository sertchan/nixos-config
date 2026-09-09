{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.lists) concatMap;
  inherit (pkgs.vimPlugins.nvim-treesitter) grammarPlugins queries;

  languages = [
    "bash"
    "c"
    "cpp"
    "css"
    "html"
    "javascript"
    "json"
    "kdl"
    "lua"
    "markdown"
    "markdown_inline"
    "nix"
    "python"
    "query"
    "rust"
    "toml"
    "tsx"
    "typescript"
    "vim"
    "vimdoc"
    "yaml"
  ];

  parserWithQueries = language: [
    grammarPlugins.${language}
    queries.${language}
  ];
in {
  programs.neovim.plugins = concatMap parserWithQueries languages;
}
