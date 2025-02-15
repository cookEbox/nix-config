{pkgs, ... }:

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
    packages = with pkgs; [ 
      neofetch
      jq
      kitty
      ranger
      gitui
      tty-clock
      nix-direnv
      lsd
      bat
      btop
      git
      zathura
      unzip
      ripgrep
      tldr
      nerdfonts
      feh
      lsof
      direnv
      nil
      lua-language-server
    ];
  };
}
