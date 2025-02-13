{pkgs, ...}: {
    home.username = "your.username";
    home.homeDirectory = "/home/your.username";
    # home.stateVersion = "22.11"; # To figure this out you can comment out the line and see what version it expected.
    programs.home-manager.enable = true;
}
{
   imports = [ 
                ../../../home/zsh
                ../../../home/rofi
                ../../../home/tmux
                ../../../home/nvim
                ../../../home/alacritty
                ../../../home/starship
	 ];
   home = { 
     # stateVersion = "23.05";
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
