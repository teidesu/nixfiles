{ abs, pkgs, ... }@inputs:

{
  imports = [
    ((import (abs "lib/containers.nix") inputs).mkDockerComposeContainer {
      directory = ./.;
    })
  ];

  systemd.tmpfiles.rules = [
    "d /mnt/puffer/Sharkey 0777 root root -"
    "d /srv/Sharkey 0777 root root -"
  ];

  services.nginx.virtualHosts."very.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";
    http2 = true;

    extraConfig = ''
      client_max_body_size 250M;
    '';
    
    locations."/" = {
      proxyPass = "http://web.sharkey.docker/";
      proxyWebsockets = true;
    };
  };
}
