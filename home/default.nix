{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ./zsh
                ./rofi
                ./tmux
                ./nvim
                ./gtk
                ./dconf
                ./alacritty
	 ];
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
       networkmanagerapplet
       mate.mate-tweak
       dconf2nix
       gnome.simple-scan
       lsd
       xxd
       bat
       btop
       git
       git-crypt
       gnupg
       thunderbird
       zathura
       onlyoffice-bin
       whatsapp-for-linux
       unzip
       cmus
       xclip
       gccgo13
       ripgrep
       go
       tldr
       nerdfonts
       hydra-check
       mpv
       android-tools
       feh
       lsof
       xdotool
       audacity
       direnv
       nil
       lua-language-server
       sqls
     ];
   };
}
