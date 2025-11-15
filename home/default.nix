{pkgs, ... }:

{
  imports = [ 
               ./ranger
	];
  home = { 
    packages = with pkgs; [ 
      nmap
      kitty
      gitui
      zathura
      feh
      nil
      lua-language-server
    ];
  };
}
