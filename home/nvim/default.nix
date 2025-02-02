{ pkgs, ... }:
{ programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      lua << EOF
      require("settings")
      require("cmp")
      require("snippets")
      vim.g.lsp_zero_extend_lspconfig = 0
      vim.defer_fn(function()
        vim.cmd [[
          require("lsp_zero")
          require("dap")
          require("telescope")
          require("harpoon")
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
    ".config/nvim/lua/settings.lua".source   = ./settings.lua;
    ".config/nvim/lua/cmp.lua".source        = ./cmp.lua;
    ".config/nvim/lua/snippets.lua".source   = ./snippets.lua;
    ".config/nvim/lua/lsp_zero.lua".source   = ./lsp_zero.lua;
    ".config/nvim/lua/dap.lua".source        = ./dap.lua;
    ".config/nvim/lua/teslescope.lua".source = ./telescope.lua;
    ".config/nvim/lua/harpoon.lua".source    = ./harpoon.lua;
  };

}

      # luafile ~/.config/nix-config/home/nvim/settings.lua
      # luafile ~/.config/nix-config/home/nvim/cmp.lua
      # luafile ~/.config/nix-config/home/nvim/snippets.lua
      #
      # lua << EOF
      # vim.g.lsp_zero_extend_lspconfig = 0
      # vim.defer_fn(function()
      #   vim.cmd [[
      #     luafile ~/.config/nix-config/home/nvim/lsp-zero.lua
      #     luafile ~/.config/nix-config/home/nvim/dap.lua
      #     luafile ~/.config/nix-config/home/nvim/telescope.lua
      #     luafile ~/.config/nix-config/home/nvim/harpoon.lua
      #   ]]
      # end, 70)
      # EOF
