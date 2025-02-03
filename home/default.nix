{ config, lib, pkgs, ... }:

{
   imports = [ 
                ./zsh
                ./rofi
                ./tmux
                ./nvim
                ./alacritty
                ./starship
	 ];
   home = { 
     stateVersion = "23.05";
     packages = with pkgs; [ 
       jq
       deja-dup
       ranger
       redshift
       gitui
       tty-clock
       nix-direnv
       qutebrowser
       nix-prefetch-git
       networkmanagerapplet
       dconf2nix
       mate.mate-tweak
       simple-scan
       lsd
       bat
       btop
       git
       git-crypt
       gnupg
       zathura
       unzip
       xclip
       ripgrep
       tldr
       nerdfonts
       hydra-check
       mpv
       feh
       lsof
       xdotool
       direnv
       nil
       lua-language-server
     ];
   };
}
