1. temp flake.nix
2. temp home-manager/home.nix 
3. ./home/nick/.nix-profile/etc/profile.d/nix.sh 
4. mkdir -p ~/.config/nix 
5. echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
6. nix run nixpkgs#home-manager -- switch --flake .#nick 
7. nix run home-manager -- switch --flake github:cookEbox/nix-config#work
If you update the github flake 
8. nix store gc
9. nix run home-manager -- switch --flake github:cookEbox/nix-config#work
