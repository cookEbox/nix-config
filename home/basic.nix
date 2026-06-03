{pkgs, ... }:

{
  imports = [ 
               ./tmux
               ./nvim
               ./starship
               ./zsh
               ./alacritty
               ./rofi
	];
  home = { 
    packages = with pkgs; [ 
      tty-clock
      zip
      emojipick
      fastfetch
      jq
      nix-direnv
      lsd
      bat
      btop
      git
      unzip
      ripgrep
      tldr
      lsof
      direnv
      kitty
    ];
  };
}
