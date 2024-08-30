{ abs, pkgs, ... } @ inputs:

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
        wireguard
        brave
        forkgram
        snipaste
        nekoray
    ]))
    (import (abs "users/teidesu/darwin.nix") inputs)
  ];

  system.stateVersion = 4; 
}

