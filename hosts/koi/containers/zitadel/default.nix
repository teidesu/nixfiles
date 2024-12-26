{ pkgs, config, ... }:

let 
  UID = 1122;
in {
  imports = [
    ./proxy.nix
  ];

  users.users.zitadel = {
    isNormalUser = true;
    uid = UID;
  };

  services.postgresql.ensureUsers = [
    { name = "zitadel"; ensureDBOwnership = true; }
  ];
  services.postgresql.ensureDatabases = [ "zitadel" ];
  desu.postgresql.ensurePasswords.zitadel = "zitadel";

  desu.secrets.zitadel-env.owner = "zitadel";

  virtualisation.oci-containers.containers.zitadel = {
    image = "ghcr.io/zitadel/zitadel:v2.66.1";
    cmd = [ "start-from-setup" "--masterkeyFromEnv" "--tlsMode" "external" ];
    environment = {
      "ZITADEL_DATABASE_POSTGRES_HOST" = "172.17.0.1";
      "ZITADEL_DATABASE_POSTGRES_PORT" = "5432";
      "ZITADEL_DATABASE_POSTGRES_DATABASE" = "zitadel";
      "ZITADEL_DATABASE_POSTGRES_USER_USERNAME" = "zitadel";
      "ZITADEL_DATABASE_POSTGRES_USER_PASSWORD" = "zitadel";
      "ZITADEL_DATABASE_POSTGRES_USER_SSL_MODE" = "disable";
      "ZITADEL_EXTERNALSECURE" = "true";
      "ZITADEL_EXTERNALDOMAIN" = "id.stupid.fish";
      "ZITADEL_EXTERNALPORT" = "443";
      "ZITADEL_TLS_ENABLED" = "false";
      "ZITADEL_WEBAUTHNNAME" = "stupid.fish";
    };
    environmentFiles = [
      config.desu.secrets.zitadel-env.path
    ];
    user = builtins.toString UID;
  };
  systemd.services.docker-zitadel.requires = [ "postgresql.service" ];

  services.nginx.virtualHosts."id.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://zitadel.docker:8080$request_uri";
      proxyWebsockets = true;
    };
  };
}