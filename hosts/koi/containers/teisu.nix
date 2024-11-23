{ config, ... } @ inputs:

let 
  UID = 1103;
in {
  desu.secrets.teisu-env.owner = "teisu";

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
      config.desu.secrets.teisu-env.path
    ];
    user = builtins.toString UID;
  };

  systemd.tmpfiles.rules = [
    "d /srv/teisu 0755 teisu teisu -"
  ];

  services.nginx.virtualHosts."tei.su" = let 
    serveWithTextPlain = {
      proxyPass = "http://teisu.docker:4321$request_uri";
      extraConfig = ''
        add_header 'Content-Type' 'text/plain';
      '';
    };
  in {
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

    locations."/keys" = serveWithTextPlain;
    locations."/keys@ssh" = serveWithTextPlain;
    locations."/keys@git" = serveWithTextPlain;
  };

  services.nginx.virtualHosts."tei.pet" = {
    forceSSL = true;
    useACMEHost = "tei.pet";

    locations."/" = {
      extraConfig = ''
        return 301 https://tei.su$request_uri;
      '';
    };
  };
}