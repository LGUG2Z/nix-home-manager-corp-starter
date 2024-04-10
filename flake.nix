{
  description = "Nix Home Manager Corp Starter";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    with inputs; let
      # FIXME: Set your own name, username and corp hostname
      defaultUsername = "LGUG2Z";
      defaultFullName = "Jeezy";
      defaultHostname = "jeezy.super.duper.big.corp.com";

      argDefaults = {
        inherit self inputs nix-index-database;
        channels = {
          inherit nixpkgs nixpkgs-unstable;
        };
      };

      nixpkgsWithOverlays = system: (import nixpkgs rec {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [];
        };
        overlays = [
          nur.overlay
          (_final: prev: {
            unstable = import nixpkgs-unstable {
              inherit (prev) system;
              inherit config;
            };
          })

          deploy-rs.overlay
          (_final: prev: {
            deploy-rs = {
              inherit (import nixpkgs {inherit system;}) deploy-rs;
              inherit (prev.deploy-rs) lib;
            };
          })
        ];
      });

      mkDarwinConfiguration = {
        system ? "aarch64-darwin",
        username ? defaultUsername,
        fullName ? defaultFullName,
        args ? {},
        modules,
      }: let
        specialArgs = argDefaults // {inherit username fullName;} // args;
      in
        darwin.lib.darwinSystem {
          inherit system specialArgs;
          pkgs = nixpkgsWithOverlays system;

          modules =
            [
              home-manager.darwinModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "hm-backup";
                  extraSpecialArgs = specialArgs;
                };
              }
            ]
            ++ modules;
        };

      mkHomeManagerConfiguration = {
        system ? "x86_64-linux",
        hostname ? defaultHostname,
        username ? defaultUsername,
        fullName ? defaultFullName,
        args ? {},
        modules,
      }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsWithOverlays system;

          extraSpecialArgs =
            {
              inherit self username fullName hostname;
            }
            // args;

          modules =
            [
              nix-index-database.hmModules.nix-index
            ]
            ++ modules;
        };
    in {
      formatter = {
        x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
        aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.alejandra;
        x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.alejandra;
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
      };

      # FIXME: If applying the Darwin configuration, this must be set to your hostname
      darwinConfigurations.YOURHOSTNAME = mkDarwinConfiguration {
        system = "aarch64-darwin";
        modules = [
          ./modules/darwin.nix
        ];
      };

      homeConfigurations.corp = mkHomeManagerConfiguration {
        system = "x86_64-linux";
        modules = [
          ./modules/home.nix
          ./modules/home-fish.nix
          ./modules/corp.nix
        ];
      };

      deploy = {
        autoRollback = false;
        magicRollback = false;
        nodes = {
          corp = rec {
            inherit (self.homeConfigurations.corp.options._module.specialArgs.value) hostname;
            sshUser = self.homeConfigurations.corp.config.home.username;
            user = self.homeConfigurations.corp.config.home.username;
            remoteBuild = true;
            profiles.dev = {
              path = (nixpkgsWithOverlays self.homeConfigurations.corp.activationPackage.system).deploy-rs.lib.activate.home-manager self.homeConfigurations.corp;
              profilePath = "/home/${user}/.local/state/nix/profiles/dev";
            };
          };
        };
      };
    };
}
