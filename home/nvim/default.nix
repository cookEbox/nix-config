{ pkgs, ... }:
{ programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      luafile ~/.config/nix-config/home/nvim/settings.lua
      luafile ~/.config/nix-config/home/nvim/cmp.lua

      lua << EOF
      vim.g.lsp_zero_extend_lspconfig = 0
      vim.defer_fn(function()
        vim.cmd [[
          luafile ~/.config/nix-config/home/nvim/lsp-zero.lua
          luafile ~/.config/nix-config/home/nvim/telescope.lua
          luafile ~/.config/nix-config/home/nvim/harpoon.lua
        ]]
      end, 70)
      EOF
    '';
    plugins = with pkgs.vimPlugins; [
      LanguageClient-neovim
      vim-tmux-navigator
      vim-nix
      plenary-nvim
      indentLine   
      undotree
      zen-mode-nvim
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
      harpoon
      telescope-nvim
      telescope_hoogle
      telescope-fzf-native-nvim
      nvim-treesitter.withAllGrammars
      neodev-nvim
      {
        plugin = nvim-ts-autotag;
        config = "lua require('nvim-ts-autotag').setup()";
      }
      {
        plugin = mason-nvim;
        config = "lua require('mason').setup()";
      }
      lsp-zero-nvim
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
      vim-easy-align
      # {
      #   plugin = friendly-snippets;
      #   config = "lua require('friendly-snippets').setup()"
      # }
    ];

  };

}
