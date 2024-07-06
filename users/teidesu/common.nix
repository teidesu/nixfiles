{ pkgs, inputs, ... }: {
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    ./fish.nix
    ./git.nix
    ./ssh.nix
  ];

  home.stateVersion = "23.11";

  programs.nix-index-database.comma.enable = true;

  home.packages = with pkgs; [
    tree
    nixpkgs-fmt
    htop
    jq
    micro
    carapace
    nil
    eza
    bat
    atuin
    inputs.agenix.packages.${system}.default
  ];
}