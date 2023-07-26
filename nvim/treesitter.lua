require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'cpp', 'javascript', 'haskell', 'elm', 'nix' },
  highlight = {
    enable = true,
  },
}
