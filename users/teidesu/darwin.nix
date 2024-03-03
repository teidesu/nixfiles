{ abs, pkgs, lib, inputs, ... }:

{
  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    scc
    ripgrep
    fnm
    aria2
    ffmpeg
    hyfetch
    wget
    watch
    curl
  ];
}
