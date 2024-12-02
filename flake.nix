{
  description = "koi nixos";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];

    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    substituters = [
      "https://nixos.tvix.store"
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    bootspec-secureboot = {
      url = "github:vikanezrimaya/bootspec-secureboot";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    desu-deploy.url = "github:teidesu/desu-deploy/a77b8e790324df51471cf40924acff9643972dfa";
    desu-deploy.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-stable
    , vscode-server
    , agenix
    , bootspec-secureboot
    , home-manager
    , nix-darwin
    , desu-deploy
    , disko
    , ...
    }:
    let
      specialArgsCommon = {
        inherit inputs;
        abs = path: ./. + ("/" + path);
      };

      mkDarwinSystem = {
        modules ? [],
        specialArgs ? {},
      }: let 
        specialArgsMerged = specialArgsCommon // specialArgs;
      in nix-darwin.lib.darwinSystem {
        modules = [
          agenix.darwinModules.default
          home-manager.darwinModules.home-manager
          { home-manager.extraSpecialArgs = specialArgsMerged; }
        ] ++ modules;
        specialArgs = specialArgsMerged;
      };

      mkNixosSystem = {
        system,
        modules ? [],
        specialArgs ? {}
      }: let 
        specialArgsMerged = specialArgsCommon // specialArgs // {
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config = { allowUnfree = true; };
          };
        };
      in nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          { home-manager.extraSpecialArgs = specialArgsMerged; }
        ] ++ modules;
        specialArgs = specialArgsMerged;
      };
    in
    {
      nixosConfigurations = {
        koi = mkNixosSystem rec {
          system = "x86_64-linux";
          modules = [
            bootspec-secureboot.nixosModules.bootspec-secureboot
            desu-deploy.nixosModules.${system}.default
            ./hosts/koi/configuration.nix
          ];
        };

        homura = mkNixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/madohomu/homura.nix
          ];
        };

        madoka = mkNixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/madohomu/madoka.nix
          ];
        };

        arumi = mkNixosSystem {
          system = "aarch64-linux";
          modules = [
            disko.nixosModules.disko
            ./hosts/arumi/configuration.nix
          ];
        };
      };

      darwinConfigurations = {
        teidesu-osx = mkDarwinSystem {
          modules = [
            ./hosts/teidesu-osx/configuration.nix
          ];
        };

        sumire = mkDarwinSystem {
          modules = [
            ./hosts/sumire/configuration.nix
          ];
        };
      };
    };
}
