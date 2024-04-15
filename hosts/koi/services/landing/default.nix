{ abs, pkgs, ... } @ inputs:

let 
  trivial = import (abs "lib/trivial.nix") inputs;
in {
  services.nginx.virtualHosts."stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";
    root = trivial.storeDirectory ./assets;
  };
}