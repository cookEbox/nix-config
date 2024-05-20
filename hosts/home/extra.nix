{ config, lib, pkgs, nixpkgs, ... }:

{
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
       brave
       zoom-us
       discord
       teams-for-linux
       xclip
       gccgo13
       krita
       virtiofsd
       mediainfo
       audacity
       gimp
       weechat
       obs-studio

       cargo
       zig
       jre8
       llvmPackages_9.clang-unwrapped
       direnv
       nodejs_20
       nil
       elmPackages.elm-language-server
       lua-language-server
       nodePackages.browser-sync
       nodePackages.typescript-language-server
       nodePackages.bash-language-server
       sqls
     ];
   };
}
