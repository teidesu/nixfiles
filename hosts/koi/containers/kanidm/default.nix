{ config, ... }:

let 
  UID = 1111;
in {
  imports = [
    ./proxy.nix
  ];

  desu.secrets.kanidm-tls-key.owner = "kanidm";
  desu.secrets.kanidm-tls-cert.owner = "kanidm";

  users.users.kanidm = {
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.kanidm = {
    image = "kanidm/server:1.4.2";
    volumes = [
      # "/srv/kanidm/data:/data/db"
      "${./server.toml}:/data/server.toml"
      "${./style.css}:/hpkg/style.css"
      "${./fish.png}:/hpkg/img/fish.png"
    ];
    
    user = "${builtins.toString UID}";

    extraOptions = [
      "--mount=type=bind,source=/srv/kanidm/data,target=/data/db"
      "--mount=type=bind,source=${config.desu.secrets.kanidm-tls-key.path},target=/data/key.pem,readonly"
      "--mount=type=bind,source=${config.desu.secrets.kanidm-tls-cert.path},target=/data/chain.pem,readonly"
    ];
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