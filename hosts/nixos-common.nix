{ abs, pkgs, ... }:

{
  nix.settings = {
    trusted-users = [ "@wheel" ];
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.kamillaova.dev/?priority=1"
    ];
  };
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  security.sudo.wheelNeedsPassword = false;

  age.identityPaths = [
    "/etc/ssh/agenix_key"
  ];

  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [
    git
    micro
    wget
    pciutils
    dnsutils
    bridge-utils
    screen
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  system.stateVersion = "23.05";
}
