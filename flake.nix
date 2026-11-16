{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
      deployAllInfra = import ./hosts/linode/infra/deploy-all.nix { 
        inherit pkgs self; 
      };
      deployCert = import ./hosts/linode/infra/deploy-cert.nix { 
        inherit pkgs self; 
      };

    in {
      packages.${system} = rec {
        forgejo = forgejoInfra.forgejo or forgejoInfra.package;
        nginx = nginxInfra.nginx or nginxInfra.package;
        certbot = pkgs.certbot;
        chatgpt-linux =
          pkgs.callPackage ./packages/chatgpt-linux { };

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
      apps.${system} = {
        deploy-forgejo = forgejoInfra.app;
        deploy-nginx = nginxInfra.app;
        deploy-all = deployAllInfra.app;
        deploy-cert = deployCert.app;
      };

      devShells.${system} = {
        # Dev shell for editing/typing-checking XMonad config with HLS.
        # Usage: nix develop
        default =
          let
            ghc = pkgs.haskellPackages.ghcWithPackages (p: [
              p.xmonad
              p.xmonad-contrib
              p.xmonad-extras
            ]);
          in
          pkgs.mkShell {
            packages = [
              ghc
              pkgs.cabal-install
              pkgs.haskell-language-server
            ];
          };
      };

      nixosConfigurations = {
        nixBox = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit unstable; };
          modules = [
            ./hosts/desktop
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # Prevent HM activation failures when a file already exists.
              # Existing files will be renamed with this extension.
              home-manager.backupFileExtension = "hm-bak";
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
              # Prevent HM activation failures when a file already exists.
              # Existing files will be renamed with this extension.
              home-manager.backupFileExtension = "hm-bak";
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
              # Prevent HM activation failures when a file already exists.
              # Existing files will be renamed with this extension.
              home-manager.backupFileExtension = "hm-bak";
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
          pkgs = import nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;

            overlays = [
              (final: prev: {
                libfyaml = prev.libfyaml.overrideAttrs (old: {
                  patches = (old.patches or []) ++ [
                    (final.fetchpatch {
                      url = "https://github.com/pantoniou/libfyaml/commit/24b18e7363b336962fe160c1dc05ca57ba95783c.diff";
                      hash = "sha256-g5QKI4HuS8MEQ9ddIQNC0j+28Dh9zLAp5RaZX5SWBHk=";
                    })
                    (final.fetchpatch {
                      url = "https://github.com/pantoniou/libfyaml/commit/9f2492ca27bb1fda64f2b12edc2da17406208b93.diff";
                      hash = "sha256-E4wS+P7R3VGrBpD7swWMMi/QPTF+9rzAeEyxhbmdiwk=";
                    })
                  ];
                });
              })
            ];
          };
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
