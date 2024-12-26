{ pkgs, config, ... }:

let 
  UID = 1121;
in {
  desu.secrets.outline-env.owner = "outline";

  users.users.outline = {
    isNormalUser = true;
    uid = UID;
  };

  services.postgresql.ensureUsers = [
    { name = "outline"; ensureDBOwnership = true; }
  ];
  services.postgresql.ensureDatabases = [ "outline" ];
  desu.postgresql.ensurePasswords.outline = "outline";

  virtualisation.oci-containers.containers.outline-redis = {
    image = "docker.io/redis:7.0-alpine";
    user = builtins.toString UID;
    extraOptions = [
      "--mount=type=bind,source=/srv/outline/redis,target=/data"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/outline/redis 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  virtualisation.oci-containers.containers.outline = {
    dependsOn = [ "outline-redis" ];
    image = "outlinewiki/outline-enterprise:0.81.1";
    volumes = [
      "${./LicenseHelper.js}:/opt/outline/build/server/utils/LicenseHelper.js"
    ];
    environment = {
      NODE_ENV = "production";
      PORT = "80";
      DATABASE_URL = "postgres://outline:outline@172.17.0.1:5432/outline"; 
      PGSSLMODE = "disable";
      REDIS_URL = "redis://outline-redis.docker:6379";
      URL = "https://wiki.stupid.fish";
      COLLABORATION_URL = "https://wiki.stupid.fish";
      FILE_STORAGE = "local";
      FILE_STORAGE_LOCAL_ROOT_DIR = "/var/lib/outline/data";
      FILE_STORAGE_UPLOAD_MAX_SIZE = "262144000";
      ENABLE_UPDATES = "false";
      WEB_CONCURRENCY = "1";
      LOG_LEVEL = "info";
    };
    environmentFiles = [
      # oidc related config + SECRET_KEY, UTILS_SECRET
      config.desu.secrets.outline-env.path
    ];
    user = builtins.toString UID;
    extraOptions = [
      "--group-add=${builtins.toString config.users.groups.geesefs.gid}"
      "--mount=type=bind,source=/mnt/s3-desu-priv-encrypted/outline,target=/var/lib/outline/data"
    ];
  };
  systemd.services.docker-outline.requires = [ "postgresql.service" "gocryptfs.service" ];

  services.nginx.virtualHosts."wiki.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://outline.docker$request_uri";
      proxyWebsockets = true;

      extraConfig = ''
        proxy_buffering off;
      '';
    };
  };
}