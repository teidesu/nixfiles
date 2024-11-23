{ pkgs, ... }:

{
  services.nginx.virtualHosts."stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";
    root = pkgs.copyPathToStore ./assets;
  };
}