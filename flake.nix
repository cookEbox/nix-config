{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      unstable = import nixpkgs-unstable {inherit system;};
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      homeManagerLib = import home-manager {inherit pkgs;};
    in {
      nixosConfigurations = {
        nixBox = lib.nixosSystem {
          inherit system;
          modules = [ 
            ./hosts/desktop
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit unstable; };
              home-manager.users.nick = {
                imports = [ ./hosts/desktop/home ];
              };
            }
          ];
        };
        nixLap = lib.nixosSystem {
          inherit system;
          modules = [ 
            ./hosts/laptop
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit unstable; };
              home-manager.users.nick = {
                imports = [ ./hosts/laptop/home ];
              };
            }
          ];
        };
        nixVM = lib.nixosSystem {
          inherit system;
          modules = [ 
            ./hosts/vm
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nick = {
                imports = [ ./hosts/vm/home ];
              };
            }
          ];
        };
      };
      homeConfigurations = {
        work = homeManagerLib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          homeDirectory = builtins.getEnv "HOME";
          username = builtins.getEnv "USER";
          modules = [
            ./hosts/work/home
          ];
          extraSpecialArgs = { 
            inherit system; 
            inherit unstable;
          };
        };
      };
    };
}
