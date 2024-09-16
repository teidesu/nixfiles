{ abs, pkgs, config, ... }@inputs:

let 
  secrets = import (abs "lib/secrets.nix");
  trivial = import (abs "lib/trivial.nix") inputs;

  UID = 1111;
  context = trivial.storeDirectory ./image;
in {
  imports = [
    (secrets.declare [{
      name = "outline-wiki-env";
      owner = "outline-wiki";
    }])
  ];

  users.users.outline-wiki = {
    isNormalUser = true;
    uid = UID;
  };

  services.postgresql.ensureUsers = [
    { name = "outline-wiki"; ensureDBOwnership = true; }
  ];
  services.postgresql.ensureDatabases = [ "outline-wiki" ];
  desu.postgresql.ensurePasswords.outline-wiki = "outline-wiki";

  virtualisation.oci-containers.containers.outline-wiki-redis = {
    image = "docker.io/redis:7.0-alpine";
    volumes = [
      "/srv/outline-wiki/redis:/data"
    ];
    user = builtins.toString UID;
  };

  systemd.services.docker-outline-wiki.serviceConfig.ExecStartPre = [
    (pkgs.writeShellScript "build-outline-wiki" ''
      docker build -t local/outline-wiki ${context}
    '')
  ];
  virtualisation.oci-containers.containers.outline-wiki = {
    dependsOn = [ "outline-wiki-redis" ];
    image = "local/outline-wiki";
    volumes = [
      "/srv/outline-wiki/media:/var/lib/outline/data"
    ];
    environment = {
      NODE_ENV = "production";
      PORT = "80";
      DATABASE_URL = "postgres://outline-wiki:outline-wiki@172.17.0.1:5432/outline-wiki";
      PGSSLMODE = "disable";
      REDIS_URL = "redis://outline-wiki-redis.docker:6379";
      URL = "https://lore.stupid.fish";
      COLLABORATION_URL = "https://lore.stupid.fish";
      FILE_STORAGE = "local";
      FILE_STORAGE_LOCAL_ROOT_DIR = "/var/lib/outline/data";
      FILE_STORAGE_UPLOAD_MAX_SIZE = "262144000";
      ENABLE_UPDATES = "false";
      WEB_CONCURRENCY = "1";
      LOG_LEVEL = "info";
      # fake license key
      LICENSE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJjYXRnaXJscyA6MyIsImV4cCI6MTc5ODc1MDgwMCwiY3VzdG9tZXJJZCI6ImNhdGdpcmxzIDozIiwic2VhdENvdW50Ijo5OTk5OTksImlzVHJpYWwiOmZhbHNlLCJpYXQiOjE3MjY0ODg2MDV9.msuM1RpFYcEpD1FMfO55PZ6-DRn1q0EIu1zjAz-oHI8";
    };
    environmentFiles = [
      # oidc related config + SECRET_KEY, UTILS_SECRET
      (secrets.file config "outline-wiki-env")
    ];
    user = builtins.toString UID;
  };
  systemd.services.docker-outline-wiki.after = [ "postgresql.service" ];

  systemd.tmpfiles.rules = [
    "d /srv/outline-wiki 0777 root root -"
  ];

  services.nginx.virtualHosts."lore.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://outline-wiki.docker$request_uri";
      proxyWebsockets = true;
    };
  };
}