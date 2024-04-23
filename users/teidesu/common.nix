{ pkgs, inputs, ... }: {
  imports = [
    ./zsh.nix
  ];

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    tree
    nixpkgs-fmt
    htop
    jq
    micro
    comma
    carapace
    inputs.nil.packages.${system}.default
    inputs.agenix.packages.${system}.default
  ];
}