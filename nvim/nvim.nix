
{ pkgs, ... }:
{
   programs.nvim = {
     enable = true;
     vimAlias = true;
     extraConfig = ''
       luafile ./settings.lua
     '';

     plugins = with pkgs.vimPlugins; [

     ];
   };

}
