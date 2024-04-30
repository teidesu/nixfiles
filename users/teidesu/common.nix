{ pkgs, inputs, ... }: {
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    ./zsh.nix
    ./git.nix
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
    inputs.agenix.packages.${system}.default
  ];
}