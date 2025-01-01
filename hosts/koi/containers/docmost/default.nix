{ pkgs, config, ... }:

let 
  UID = 1124;
  context = pkgs.copyPathToStore ./image;
in {
  desu.secrets.docmost-env.owner = "docmost";

  users.users.docmost = {
    isNormalUser = true;
    uid = UID;
  };

  services.postgresql.ensureUsers = [
    { name = "docmost"; ensureDBOwnership = true; }
  ];
  services.postgresql.ensureDatabases = [ "docmost" ];
  desu.postgresql.ensurePasswords.docmost = "docmost";

  virtualisation.oci-containers.containers.docmost-redis = {
    image = "docker.io/redis:7.0-alpine";
    user = builtins.toString UID;
    extraOptions = [
      "--mount=type=bind,source=/srv/docmost/redis,target=/data"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/docmost/redis 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  systemd.services.docker-docmost.serviceConfig.ExecStartPre = [
    (pkgs.writeShellScript "build-docmost" ''
      docker build -t local/docmost ${context}
    '')
  ];
  virtualisation.oci-containers.containers.docmost = {
    dependsOn = [ "docmost-redis" ];
    image = "local/docmost";
    environment = {
      APP_URL = "https://docmost.stupid.fish";
      PORT = "80";
      DATABASE_URL = "postgres://docmost:docmost@172.17.0.1:5432/docmost?sslmode=disable";
      REDIS_URL = "redis://docmost-redis.docker:6379";
      STORAGE_DRIVER = "local";
      FILE_UPLOAD_SIZE_LIMIT = "100mb";
      MAIL_DRIVER = "smtp";
    };
    environmentFiles = [
      # oidc related config + SECRET_KEY, UTILS_SECRET
      config.desu.secrets.docmost-env.path
    ];
    user = builtins.toString UID;
    extraOptions = [
      "--group-add=${builtins.toString config.users.groups.geesefs.gid}"
      "--mount=type=bind,source=/mnt/s3-desu-priv-encrypted/docmost,target=/app/data/storage"
    ];
  };
  systemd.services.docker-docmost.requires = [ "postgresql.service" "gocryptfs.service" ];

  services.nginx.virtualHosts."docmost.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://docmost.docker$request_uri";
      proxyWebsockets = true;

      extraConfig = ''
        proxy_buffering off;
      '';
    };
  };
}