
{ pkgs, ... }:
{
   programs.neovim = {
     enable = true;
     vimAlias = true;
     extraConfig = ''
       luafile ./settings.lua
     '';

     plugins = with pkgs.vimPlugins; [

     ];
   };

}
