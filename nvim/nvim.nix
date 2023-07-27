{ pkgs, ... }:
{
  programs.neovim = {
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

    plugins = with pkgs.vimPlugins; [
      indentLine   
      vim-nix
      gruvbox-nvim
      nvim-treesitter.withAllGrammars
      nvim-lspconfig
      nvim-compe
      haskell-tools-nvim
      undotree
      lualine-nvim
      comment-nvim
      nvim-autopairs
      nvim-surround
      luasnip
    ];
  };

}
