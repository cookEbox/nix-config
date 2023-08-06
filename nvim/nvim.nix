{pkgs, ... }:
{ programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      luafile ~/.config/nix-config/nvim/settings.lua
      luafile ~/.config/nix-config/nvim/cmp.lua

      lua << EOF
      vim.defer_fn(function()
        vim.cmd [[
          luafile ~/.config/nix-config/nvim/lsp.lua
        ]]
      end, 70)
      EOF
    '';
    plugins = with pkgs.vimPlugins; [
      vim-nix
      plenary-nvim
      indentLine   
      undotree
      {
        plugin = gruvbox-nvim;
        config = "colorscheme gruvbox";
      }
      {
        plugin = lualine-nvim;
        config = "lua require('lualine').setup()";
      }
      {
        plugin = comment-nvim;
        config = "lua require('Comment').setup()";
      }
      {
        plugin = nvim-autopairs;
        config = "lua require('nvim-autopairs').setup({check_ts = true})";
      }
      {
        plugin = nvim-surround;
        config = "lua require('nvim-surround').setup()";
      }
      {
        plugin = telescope-nvim;
        config = "lua require('telescope').setup()";
      }
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
      {
        plugin = mason-nvim;
        config = "lua require('mason').setup()";
      }
      {
        plugin = mason-lspconfig-nvim;
        config = ''
          lua << EOF
          require('mason-lspconfig').setup {
            ensure_installed = { "bashls", "clangd", "dockerls", "elmls", "html", "jsonls", "rnix", "rust_analyzer", "tsserver", "lua_ls", "sqlls", "lemminx"
            },
          }
          EOF
          '';
      }
      nvim-lspconfig
      lspkind-nvim
      nvim-cmp
      {
        plugin = cmp-nvim-lsp;
        config = "lua after = 'nvim-cmp'";
      }
      {
        plugin = cmp-buffer;
        config = "lua after = 'nvim-cmp'";
      }
      {
        plugin = cmp-path;
        config = "lua after = 'nvim-cmp'";
      }
      {
        plugin = cmp-cmdline;
        config = "lua after = 'nvim-cmp'";
      }
      luasnip
      cmp_luasnip
      {
        plugin = snippets-nvim;
        config = "lua require('snippets').use_suggested_mappings()";
      }
      {
        plugin = nvim-compe;
        # config = "let g:completion_enable_snippet = 'snippets.nvim'";
      }
    ];

  };

}
