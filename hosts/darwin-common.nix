{ inputs, ... }: 

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
    settings.sandbox = "relaxed";
  };

  services.nix-daemon.enable = true;
  # nixpkgs.flake.source = lib.mkForce null;

  security.pam.enableSudoTouchIdAuth = true;
  programs.fish.enable = true;
}