{ abs, config, ... } @ inputs:

let 
  secrets = import (abs "lib/secrets.nix");

  UID = 1103;
in {
  imports = [
    (secrets.declare [{
      name = "teisu-env";
      owner = "teisu";
    }])
  ];

  users.users.teisu = {
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.teisu = {
    image = "ghcr.io/teidesu/tei.su:sha-e6a632c@sha256:1f6da149f278d05136155ff9faa858565dcb5ab66c429cba6839f731879fcf71";
    volumes = [
      "/srv/teisu:/app/.runtime"
    ];
    environmentFiles = [
      (secrets.file config "teisu-env")
    ];
    user = builtins.toString UID;
  };

  systemd.tmpfiles.rules = [
    "d /srv/teisu 0755 teisu teisu -"
  ];

  services.nginx.virtualHosts."tei.su" = {
    forceSSL = true;
    useACMEHost = "tei.su";

    locations."/" = {
      proxyPass = "http://teisu.docker:4321/";
    };

    locations."/.well-known/" = {
      proxyPass = "http://teisu.docker:4321/.well-known/";
      extraConfig = ''
        add_header 'Access-Control-Allow-Origin' '*';
      '';
    };
  };
}