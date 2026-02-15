{ pkgs, unstable, ... }:

{
  imports = [ 
               ./gtk
               ./emacs
	];
  home = { 
    packages = with pkgs; [ 

      nftables
      lutris
      ferium
      brave
      unstable.ladybird
      zoom-us
      discord
      teams-for-linux
      rclone
      android-file-transfer
      thunderbird
      evolutionWithPlugins
      onlyoffice-desktopeditors
      deja-dup
      redshift
      networkmanagerapplet
      simple-scan
      mate.mate-tweak
      dconf2nix
      gnupg
      xclip
      hydra-check
      xdotool
      git-crypt
      nix-prefetch-git
      qutebrowser
      mpv
      wasistlos
      cmus
      gccgo13
      go
      android-tools
      xclip
      gccgo13
      krita
      virtiofsd
      mediainfo
      audacity
      gimp
      weechat
      obs-studio
      direnv
      nodePackages.bash-language-server
      freecad
      # kicad
      keymapp
      mesa-demos
      protonvpn-gui
      xournalpp
      jdk17
      wineWowPackages.staging 
      winetricks 
    ];
  };
}
