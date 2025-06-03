{ config, lib, pkgs, unstable, ... }:

{
   imports = [ 
                ./gtk
                ./emacs
                ./zsh
	 ];
   home = { 
     packages = with pkgs; [ 
       ferium
       brave
       unstable.ladybird
       zoom-us
       discord
       teams-for-linux
       rclone
       android-file-transfer
       thunderbird
       onlyoffice-bin
       deja-dup
       redshift
       networkmanagerapplet
       simple-scan
       mate.mate-tweak
       dconf2nix
       gnupg
       xclip
       hydra-check
       xdotool
       git-crypt
       nix-prefetch-git
       qutebrowser
       mpv
       whatsapp-for-linux
       cmus
       gccgo13
       go
       android-tools
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
       llvmPackages_latest.clang-unwrapped
       direnv
       nodejs_20
       elmPackages.elm-language-server
       lua-language-server
       nodePackages.browser-sync
       nodePackages.typescript-language-server
       nodePackages.bash-language-server
       sqls
     ];
   };
}
