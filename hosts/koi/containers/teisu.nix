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
    image = "ghcr.io/teidesu/tei.su:latest";
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
      proxyPass = "http://teisu.docker:4321$request_uri";
      extraConfig = ''
        if ($request_method = MEOW) {
          rewrite ^ /.meow-proxy last;
        }
      '';
    };

    locations."/.well-known/" = {
      proxyPass = "http://teisu.docker:4321$request_uri";
      extraConfig = ''
        add_header 'Access-Control-Allow-Origin' '*';
      '';
    };

    locations."/.meow-proxy" = {
      proxyPass = "http://teisu.docker:4321/api/meow";
      extraConfig = ''
        proxy_method GET;
        internal;
      '';
    };
  };
}