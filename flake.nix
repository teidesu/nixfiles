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
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    , ...
    }:
    let
      specialArgs = {
        inherit inputs;
        abs = path: ./. + ("/" + path);
      };
    in
    {
      nixosConfigurations = {
        koi = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            agenix.nixosModules.default
            bootspec-secureboot.nixosModules.bootspec-secureboot
            home-manager.nixosModules.home-manager
            { home-manager.extraSpecialArgs = specialArgs; }
            ./hosts/koi/configuration.nix
          ];
          specialArgs = specialArgs // {
            pkgs-stable = import nixpkgs-stable {
              system = "x86_64-linux";
              config = { allowUnfree = true; };
            };
          };
        };
      };

      darwinConfigurations = {
        teidesu-osx = nix-darwin.lib.darwinSystem {
          modules = [
            agenix.darwinModules.default
            home-manager.darwinModules.home-manager
            { home-manager.extraSpecialArgs = specialArgs; }
            ./hosts/teidesu-osx/configuration.nix
          ];
          inherit specialArgs;
        };

        airi = nix-darwin.lib.darwinSystem {
          modules = [
            agenix.darwinModules.default
            home-manager.darwinModules.home-manager
            { home-manager.extraSpecialArgs = specialArgs; }
            ./hosts/airi/configuration.nix
          ];
          inherit specialArgs;
        };
      };
    };
}
