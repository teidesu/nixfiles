{ pkgs, inputs, ... }: {
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    ./zsh.nix
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
    inputs.nil.packages.${system}.default
    inputs.agenix.packages.${system}.default
  ];
}