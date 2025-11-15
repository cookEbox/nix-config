{pkgs, ... }:

{
  imports = [ 
               ./tmux
               ./macKitty
               ./nvim
               ./starship
               ./zsh
	];
  home = { 
    packages = with pkgs; [ 
      zip
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
      qutebrowser
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
