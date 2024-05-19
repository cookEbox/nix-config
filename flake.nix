{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        nixBox = lib.nixosSystem {
          inherit system;
          modules = [ 
            ./hosts/desktop
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nick = {
                imports = [ ./home ];
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
              home-manager.users.nick = {
                imports = [ ./home ];
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
                imports = [ ./home ];
              };
            }
          ];
        };
      };
    };
}
