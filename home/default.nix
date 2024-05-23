{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ./zsh
                ./tmux
                ./nvim
                ./gtk
	 ];
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
       mate.mate-tweak
       mate.mate-applets
       calc
       bat
       btop
       git
       git-crypt
       gnupg
       thunderbird
       eza
       zathura
       onlyoffice-bin
       whatsapp-for-linux
       unzip
       cmus
       xclip
       gccgo13
       ripgrep
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
