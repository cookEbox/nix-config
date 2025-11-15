{pkgs, ... }:

{
  imports = [ 
               ./ranger
	];
  home = { 
    packages = with pkgs; [ 
      nmap
      gitui
      zathura
      feh
      nil
      lua-language-server
    ];
  };
}
