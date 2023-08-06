{ pkgs, ... }:
{ programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      lua << EOF
      vim.defer_fn(function()
        vim.cmd [[
          luafile ~/.config/nix-config/nvim/settings.lua
          luafile ~/.config/nix-config/nvim/lsp.lua
        ]]
      end, 70)
      EOF
    '';

# require('lualine').setup{}
# require('Comment').setup{}
# require('nvim-autopairs').setup{}
# require('nvim-surround').setup{}
# require('haskell-tools').setup{}
# require('telescope').setup{}
# -- require('luasnip').setup{}
# -- require('nvim-cmp').setup {}
# -- require('cmp-nvim-lsp').setup {}
# -- require('cmp_luasnip').setup {}
#
# require('compe').setup {
#   enabled = true;
#   autocomplete = true;
#   debug = false;
#   min_length = 1;
#   preselect = 'enable';
#   throttle_time = 88;
#   source_timeout = 200;
#   incomplete_delay = 400;
#   max_abbr_width = 100;
#   max_kind_width = 100;
#   max_menu_width = 100;
#   documentation = false;
#
#   source = {
#     path = true;
#     buffer = true;
#     nvim_lsp = true;
#     nvim_lua = true;
#     tags = true;
#     treesitter = true;
#   };
# }

    plugins = with pkgs.vimPlugins; [
      vim-nix
      plenary-nvim
      indentLine   
      {
        plugin = gruvbox-nvim;
        config = "colorscheme gruvbox";
      }
      {
        plugin = nvim-lspconfig;
        config = "lua require(nvim-lspconfig)";
      }
      {
        plugin = nvim-compe;
        config = ''
          lua << EOF
            require('compe').setup {
              enabled = true;
              autocomplete = true;
              debug = false;
              min_length = 1;
              preselect = 'enable';
              throttle_time = 88;
              source_timeout = 200;
              incomplete_delay = 400;
              max_abbr_width = 100;
              max_kind_width = 100;
              max_menu_width = 100;
              documentation = false;

              source = {
                path = true;
                buffer = true;
                nvim_lsp = true;
                nvim_lua = true;
                tags = true;
                treesitter = true;
              };
            }
            EOF
        '';
      }
      nvim-compe
      haskell-tools-nvim
      undotree
      lualine-nvim
      comment-nvim
      nvim-autopairs
      nvim-surround
      nvim-cmp
      cmp-nvim-lsp
      luasnip
      cmp_luasnip
      telescope-nvim
      {
        plugin = nvim-treesitter;
        config = ''
          lua << EOF
          require('nvim-treesitter.configs').setup {
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
          }
          EOF
          '';
      }
    ];
  };

}
