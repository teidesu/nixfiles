{ abs, pkgs, config, ... } @ inputs:

let 
  secrets = import (abs "lib/secrets.nix");
  trivial = import (abs "lib/trivial.nix") inputs;

  configDrv = trivial.storeDirectory ./config;

  UID = 1100;
in {
  imports = [
    (secrets.declare [{
      name = "verdaccio-htpasswd";
      owner = "verdaccio";
    }])
  ];

  users.users.verdaccio = {
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.verdaccio = {
    image = "verdaccio/verdaccio:5.31@sha256:c77fec2127a1c3d17fc0795786f1e1bd88258e6d7af1835786ced4f7c7287da8";
    volumes = [
      "${configDrv}:/verdaccio/conf"
      "${secrets.file config "verdaccio-htpasswd"}:/verdaccio/htpasswd"
      "/srv/verdaccio/storage:/verdaccio/storage"
      "/srv/verdaccio/plugins:/verdaccio/plugins"
    ];
    environment = {
      VERDACCIO_PUBLIC_URL = "https://npm.tei.su";
    };
    user = builtins.toString UID;
  };

  systemd.tmpfiles.rules = [
    "d /srv/verdaccio 0755 verdaccio verdaccio -"
  ];

  services.nginx.virtualHosts."npm.tei.su" = {
    forceSSL = true;
    useACMEHost = "tei.su";

    locations."/" = {
      proxyPass = "http://verdaccio.docker:4873$request_uri";

      # https://verdaccio.org/docs/reverse-proxy
      extraConfig = ''
        proxy_set_header X-Forwarded-For $http_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_redirect off;
      '';
    };
  };
}