require('nvim-treesitter.configs').setup {
  parser_install_dir = "~/.vim",
  ensure_installed = { 'c', 'cpp', 'javascript', 'haskell', 'elm', 'nix' },
  highlight = {
    enable = true,
  },
}
