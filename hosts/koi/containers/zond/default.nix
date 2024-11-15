{ abs, config, ... }:

let 
  secrets = import (abs "lib/secrets.nix");

  UID = 1116;
in {
  # todo 2: update UMAMI_HOST in teisu-env

  imports = [
    (secrets.declare [
      {
        name = "umami-env";
        owner = "umami";
      }
    ])
  ];

  users.users.umami = {
    isNormalUser = true;
    uid = UID;
  };

  services.postgresql.ensureUsers = [
    { name = "umami"; ensureDBOwnership = true; }
  ];
  services.postgresql.ensureDatabases = [ "umami" ];
  desu.postgresql.ensurePasswords.umami = "umami";

  systemd.services.docker-umami.after = [ "postgresql.service" ];
  virtualisation.oci-containers.containers.umami = {
    image = "ghcr.io/umami-software/umami:postgresql-v2.13.2";

    environment = {
      DATABASE_TYPE = "postgresql";
      DATABASE_URL = "postgresql://umami:umami@172.17.0.1:5432/umami";
      DISABLE_TELEMETRY = "1";
      DISABLE_UPDATES = "1";
    };

    environmentFiles = [
      (secrets.file config "umami-env")
    ];

    user = "${builtins.toString UID}";
  };

  services.nginx.virtualHosts."zond.tei.su" = {
    forceSSL = true;
    useACMEHost = "tei.su";
    
    locations."/" = {
      proxyPass = "http://umami.docker:3000$request_uri";
    };
  };
}