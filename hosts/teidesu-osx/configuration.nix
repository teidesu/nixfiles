{ pkgs
, lib
, abs
, inputs
, ...
}:

{
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.trusted-users = [ "@admin" ];

    useDaemon = true;
    
    registry = {
      nixpkgs.to = {
        type = "github";
        owner = "NixOS";
        repo = "nixpkgs";
        rev = inputs.nixpkgs.rev;
      };
    };

    settings.nix-path = [ "nixpkgs=flake:nixpkgs" ];
  };
  # nixpkgs.flake.source = lib.mkForce null;

  nixpkgs.hostPlatform = "aarch64-darwin";
  services.nix-daemon.enable = true;

  age.identityPaths = [
    "/Users/teidesu/.ssh/agenix_key"
  ];

  security.pam.enableSudoTouchIdAuth = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  programs.zsh.enable = true;

  imports = [
    (import (abs "users/teidesu/darwin.nix") {
      home = {
        imports = [
          ./arc-setup.nix
        ];
      };
    })
  ];

  system.stateVersion = 4;
}

