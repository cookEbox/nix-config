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
        work = home-manager.lib.homeManagerConfiguration {
          inherit system;
          pkgs = import nixpkgs { inherit system; };
          modules = [
            ./hosts/work/home
          ];
          # Optionally include these if desired in your work configuration:
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit unstable; };
        };
      };
    };
}
