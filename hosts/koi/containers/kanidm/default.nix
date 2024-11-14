{ abs, pkgs, config, ... }@inputs:

let 
  secrets = import (abs "lib/secrets.nix");

  UID = 1111;
in {
  imports = [
    (secrets.declare [
      {
        name = "kanidm-tls-key";
        owner = "kanidm";
      }
      {
        name = "kanidm-tls-cert";
        owner = "kanidm";
      }
    ])
    ./proxy.nix
  ];
  users.users.kanidm = {
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.kanidm = {
    image = "kanidm/server:1.4.2";
    volumes = [
      "/srv/kanidm/data:/data/db"
      "${./server.toml}:/data/server.toml"
      "${./style.css}:/hpkg/style.css"
      "${./fish.png}:/hpkg/img/fish.png"
      "${(secrets.file config "kanidm-tls-key")}:/data/key.pem"
      "${(secrets.file config "kanidm-tls-cert")}:/data/chain.pem"
    ];
    
    user = "${builtins.toString UID}";
  };

  systemd.tmpfiles.rules = [
    "d /srv/kanidm/data 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  services.nginx.virtualHosts."id.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "https://kanidm.docker:8443$request_uri";
      proxyWebsockets = true;
    };
  };
}