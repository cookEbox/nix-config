{ pkgs, ... }:
{ programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      lua << EOF
      require("settings")
      require("cmp_config")
      require("snippets_config")
      vim.g.lsp_zero_extend_lspconfig = 0
      vim.defer_fn(function()
        require("lsp_zero")
        require("dap_config")
        require("telescope_config")
      end, 70)
      EOF
    '';
    plugins = with pkgs.vimPlugins; [
      LanguageClient-neovim
      vim-tmux-navigator
      vim-nix
      plenary-nvim
      indentLine   
      context-vim
      undotree
      zen-mode-nvim
      nvim-metals
      nvim-dap-ui
      telescope-dap-nvim
      {
        plugin = gruvbox-nvim;
        config = "colorscheme gruvbox";
      }
      {
        plugin = which-key-nvim;
        config = "lua require('lualine').setup()";
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
      friendly-snippets
    ];

  };
  home.file = { 
    ".config/nvim/lua/settings.lua".source          = ./settings.lua;
    ".config/nvim/lua/cmp_config.lua".source        = ./cmp_config.lua;
    ".config/nvim/lua/snippets_config.lua".source   = ./snippets_config.lua;
    ".config/nvim/lua/lsp_zero.lua".source          = ./lsp_zero.lua;
    ".config/nvim/lua/dap_config.lua".source        = ./dap_config.lua;
    ".config/nvim/lua/telescope_config.lua".source  = ./telescope_config.lua;
    ".config/nvim/lua/oil_config.lua".source        = ./oil_config.lua;
  };

}
