{ abs, pkgs, config, ... }@inputs:

let 
  secrets = import (abs "lib/secrets.nix");

  UID = 1110;
  sharedConfig = {
    image = "ghcr.io/goauthentik/server:2024.8.2";
    dependsOn = [ "authentik-redis" ];
    environment = {
      AUTHENTIK_POSTGRESQL__HOST = "172.17.0.1";
      AUTHENTIK_POSTGRESQL__USER = "authentik";
      AUTHENTIK_POSTGRESQL__PASSWORD = "authentik";
      AUTHENTIK_POSTGRESQL__NAME = "authentik";
      AUTHENTIK_REDIS__HOST = "authentik-redis.docker";
    };
    volumes = [
      "/mnt/puffer/authentik/media:/media"
      "/mnt/puffer/authentik/templates:/templates"
    ];
    user = builtins.toString UID;
    environmentFiles = [
      (secrets.file config "authentik-env")
    ];
  };
in {
  imports = [
    # email related + AUTHENTIK_SECRET_KEY
    (secrets.declare [{
      name = "authentik-env";
      owner = "authentik";
    }])
  ];

  users.users.authentik = {
    isNormalUser = true;
    uid = UID;
  };

  services.postgresql.ensureUsers = [
    { name = "authentik"; ensureDBOwnership = true; }
  ];
  services.postgresql.ensureDatabases = [ "authentik" ];
  desu.postgresql.ensurePasswords.authentik = "authentik";

  virtualisation.oci-containers.containers.authentik-redis = {
    image = "docker.io/redis:7.0-alpine";
    volumes = [
      "/mnt/puffer/authentik/redis:/data"
    ];
    user = builtins.toString UID;
  };

  virtualisation.oci-containers.containers.authentik-server = sharedConfig // {
    cmd = [ "server" ];
  };
  systemd.services.docker-authentik-server.after = [ "postgresql.service" ];

  virtualisation.oci-containers.containers.authentik-worker = sharedConfig // {
    cmd = [ "worker" ];
  };
  systemd.services.docker-authentik-worker.after = [ "postgresql.service" ];

  systemd.tmpfiles.rules = [
    "d /mnt/puffer/authentik 0777 root root -"
  ];

  services.nginx.virtualHosts."id.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://authentik-server.docker:9000$request_uri";
      proxyWebsockets = true;
    };
  };
}