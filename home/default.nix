{ config, lib, pkgs, nixpkgs, ... }:

{
   imports = [ 
                ./zsh
                ./rofi
                ./tmux
                ./nvim
                ./gtk
                ./alacritty
                ./starship
                ./emacs
	 ];
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
       ranger
       redshift
       gitui
       tty-clock
       qutebrowser
       nix-direnv
       nix-prefetch-git
       networkmanagerapplet
       mate.mate-tweak
       dconf2nix
       gnome.simple-scan
       lsd
       android-file-transfer
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
