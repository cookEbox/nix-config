{pkgs, ... }:

{
  imports = [ 
               ./alacritty
               ./ranger
	];
  home = { 
    packages = with pkgs; [ 
      nmap
      emojipick
      kitty
      gitui
      zathura
      feh
      nil
      lua-language-server
    ];
  };
}
