{ pkgs
, abs
, inputs
, ...
}:

{
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.trusted-users = [ "@admin" ];

    useDaemon = true;
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  services.nix-daemon.enable = true;

  age.identityPaths = [
    "/Users/teidesu/.ssh/agenix_key"
  ];

  security.pam.enableSudoTouchIdAuth = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  programs.zsh.enable = true;

  users.users.teidesu = {
    home = "/Users/teidesu";
  };

  home-manager.users.teidesu = { pkgs, ... }: {
    imports = [
      (abs "users/teidesu/darwin.nix")

      ./arc-setup.nix
    ];
  };

  system.stateVersion = 4;
}

