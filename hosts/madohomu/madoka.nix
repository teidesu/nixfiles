{ ... }:

{
  imports = [
    ./common.nix
    ./services/uptime-kuma.nix
  ];
  
  networking.hostName = "madoka";
}