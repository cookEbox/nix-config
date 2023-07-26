{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      luafile ~/.config/nix-config/nvim/settings.lua
    '';

    plugins = with pkgs.vimPlugins; [
      indentLine   
      vim-nix
      gruvbox-nvim
    ];
  };

}
