{pkgs, ... }:

{
  imports = [ 
               ./rofi
               ./tmux
               ./nvim
               ./alacritty
               ./starship
	];
  home = { 
    packages = with pkgs; [ 
      neofetch
      emojipick
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
      feh
      lsof
      direnv
      nil
      lua-language-server
      mesa-demos
    ];
  };
  home.file = {
    ".config/direnv/direnv.toml" = {
      text = ''
        hide_env_diff = true
      '';
    };
  };
}
