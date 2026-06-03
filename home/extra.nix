{ pkgs, unstable, ... }:

{
  imports = [ 
               ./gtk
               ./emacs
	];
  home = { 
    packages = with pkgs; [ 

      nftables
      figlet
      toilet
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
      mate-tweak
      dconf2nix
      gnupg
      xclip
      hydra-check
      xdotool
      git-crypt
      nix-prefetch-git
      mpv
      karere
      # wasistlos
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
      bash-language-server
      freecad
      # kicad
      keymapp
      mesa-demos
      proton-vpn
      xournalpp
      jdk17
      wineWow64Packages.staging 
      winetricks 
      claude-code
    ];
  };
}
