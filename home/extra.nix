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
       direnv
       nodePackages.bash-language-server
     ];
   };
}
