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
      neofetch
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
    ];
  };
  home = {
    file = {
      ".config/direnv/direnv.toml" = {
        text = ''
          hide_env_diff = true
        '';
      };
    };
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
