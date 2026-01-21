{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-unstable }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      unstable = import nixpkgs-unstable {inherit system;};
      pkgs = import nixpkgs { inherit system; };
      forgejoInfra = import ./hosts/linode/infra/forgejo/deploy-forgejo.nix {
        inherit pkgs self;
      };
      nginxInfra = import ./hosts/linode/infra/nginx/deploy-nginx.nix {
        inherit pkgs self;
      };

    in {
      packages.${system} = rec {
        forgejo = forgejoInfra.forgejo or forgejoInfra.package;
        nginx = nginxInfra.nginx or nginxInfra.package;

        tools = pkgs.buildEnv {
          name = "nix-config-tools";
          paths = with pkgs; [ git ripgrep jq tmux neovim ];
        };

        default = tools;
      };
      # packages.${system} = { 
      #   forgejo = forgejoInfra.forgejo;
      #   nginx = nginxInfra.nginx;
      # };
      # apps.${system} = { 
      #   deploy-forgejo = forgejoInfra.app;
      #   deploy-nginx = nginxInfra.app;
      # };

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
        # pi = home-manager.lib.homeManagerConfiguration {
        #   pkgs = nixpkgs.legacyPackages.aarch64-linux;
        #   modules = [
        #     ./hosts/pi/home
        #   ];
        # };
        work = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./hosts/work/home
          ];
        };
        workMac = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [
            ./hosts/workMac/home
          ];
        };
        linode = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./hosts/linode/home
          ];
        };
      };
    };
}
