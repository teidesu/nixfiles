{ pkgs
, lib
, abs
, ...
}@inputs:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  programs.zsh.enable = true;

  imports = [
    ../darwin-common.nix
    (import (abs "lib/darwin/apps") inputs (apps: with apps; [
        alacritty
        raycast
        karabiner
    ]))
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

