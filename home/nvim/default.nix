{ pkgs, ... }:

let
  luaPlugin = plugin: {
    inherit plugin;
    type = "lua";
  };

  luaPluginWithConfig = plugin: config: {
    inherit plugin config;
    type = "lua";
  };
in
{
  programs.neovim = {
    enable = true;
    vimAlias = true;

    withRuby = true;
    withPython3 = true;

    # Keep core language servers available to Neovim even when it is opened
    # outside a project-specific `nix develop` shell.
    extraPackages = with pkgs; [
      # Haskell
      haskell-language-server

      # Scala / Metals
      metals
      coursier
      jdk17

      # Nix / Lua servers used by lsp.lua
      nil
      lua-language-server

      # General CLI tooling already used by this config
      curl
      nodejs_22
      gh
      lynx
      gnumake
      gcc
    ];

    extraConfig = ''
      let $NVIM_METALS_JAVA_HOME = '${pkgs.jdk17}/lib/openjdk'
      let $NVIM_METALS_CMD = '${pkgs.metals}/bin/metals'

      lua << EOF
      require("settings")
      require("oil_config")
      require("cmp_config")
      require("snippets_config")
      require("copilot_config")
      require("copilot_chat_config")
      require("avante_config")

      vim.defer_fn(function()
        require("lsp")
        require("dap_config")
        require("telescope_config")
      end, 70)
      EOF
    '';

    plugins = with pkgs.vimPlugins; [
      haskell-tools-nvim
      vim-tmux-navigator
      vim-nix
      diffview-nvim
      plenary-nvim
      indentLine
      context-vim
      undotree
      zen-mode-nvim
      nvim-metals
      nvim-dap
      nvim-dap-ui
      telescope-dap-nvim
      oil-nvim
      nvim-web-devicons
      nui-nvim
      avante-nvim
      copilot-lua
      CopilotChat-nvim

      (luaPluginWithConfig gruvbox-nvim ''
        vim.cmd.colorscheme("gruvbox")
      '')

      (luaPluginWithConfig which-key-nvim ''
        require("which-key").setup({})
      '')

      (luaPluginWithConfig lualine-nvim ''
        require("lualine").setup({})
      '')

      (luaPluginWithConfig comment-nvim ''
        require("Comment").setup({})
      '')

      (luaPluginWithConfig nvim-autopairs ''
        require("nvim-autopairs").setup({
          check_ts = true
        })
      '')

      (luaPluginWithConfig nvim-surround ''
        require("nvim-surround").setup({})
      '')

      harpoon
      telescope-nvim
      telescope_hoogle
      telescope-fzf-native-nvim
      nvim-treesitter.withAllGrammars
      neodev-nvim

      (luaPluginWithConfig nvim-ts-autotag ''
        require("nvim-ts-autotag").setup({})
      '')

      (luaPluginWithConfig mason-nvim ''
        require("mason").setup({})
      '')

      lspkind-nvim
      nvim-cmp

      (luaPlugin cmp-nvim-lsp)
      (luaPlugin cmp-buffer)
      (luaPlugin cmp-path)
      (luaPlugin cmp-cmdline)

      luasnip
      cmp_luasnip

      (luaPluginWithConfig snippets-nvim ''
        require("snippets").use_suggested_mappings()
      '')

      vim-easy-align
      friendly-snippets
    ];
  };

  home.file = {
    ".config/nvim/lua/settings.lua".source = ./settings.lua;
    ".config/nvim/lua/cmp_config.lua".source = ./cmp_config.lua;
    ".config/nvim/lua/snippets_config.lua".source = ./snippets_config.lua;
    ".config/nvim/lua/lsp.lua".source = ./lsp.lua;
    ".config/nvim/lua/dap_config.lua".source = ./dap_config.lua;
    ".config/nvim/lua/telescope_config.lua".source = ./telescope_config.lua;
    ".config/nvim/lua/oil_config.lua".source = ./oil_config.lua;
    ".config/nvim/lua/avante_config.lua".source = ./avante_config.lua;
    ".config/nvim/lua/copilot_config.lua".source = ./copilot_config.lua;
    ".config/nvim/lua/copilot_chat_config.lua".source = ./copilot_chat_config.lua;
  };
}
