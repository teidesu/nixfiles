{ abs, pkgs, config, ... }@inputs:

let 
  secrets = import (abs "lib/secrets.nix");

  UID = 1115;
in {
  imports = [
    (secrets.declare [
      {
        name = "wakapi-env";
        owner = "wakapi";
      }
    ])
  ];

  users.users.wakapi = {
    isNormalUser = true;
    uid = UID;
  };

  services.postgresql.ensureUsers = [
    { name = "wakapi"; ensureDBOwnership = true; }
  ];
  services.postgresql.ensureDatabases = [ "wakapi" ];
  desu.postgresql.ensurePasswords.wakapi = "wakapi";

  systemd.services.docker-wakapi.after = [ "postgresql.service" ];
  virtualisation.oci-containers.containers.wakapi = {
    image = "ghcr.io/muety/wakapi:2.12.2";
    volumes = [
      "/srv/wakapi:/data"
    ];

    environment = {
      WAKAPI_DB_TYPE = "postgres";
      WAKAPI_DB_HOST = "172.17.0.1";
      WAKAPI_DB_PORT = "5432";
      WAKAPI_DB_NAME = "wakapi";
      WAKAPI_DB_USER = "wakapi";
      WAKAPI_DB_PASSWORD = "wakapi";
      WAKAPI_DB_SSL = "false";

      WAKAPI_PUBLIC_URL = "https://waka.stupid.fish";
      WAKAPI_LISTEN_IPV4 = "0.0.0.0";
      WAKAPI_LISTEN_IPV6 = "-";
      WAKAPI_ALLOW_SIGNUP = "false";
      WAKAPI_DISABLE_FRONTPAGE = "false";
      WAKAPI_MAIL_SENDER = "waka.stupid.fish <alina@tei.su>";
      WAKAPI_MAIL_SMTP_HOST = "smtp.mail.me.com";
      WAKAPI_MAIL_SMTP_PORT = "587";
      WAKAPI_MAIL_SMTP_USERNAME = "teidesu@icloud.com";
      WAKAPI_MAIL_SMTP_TLS = "false";
      WAKAPI_AVATAR_URL_TEMPLATE = "https://t.me/i/userpic/320/{username}.jpg";
    };

    environmentFiles = [
      (secrets.file config "wakapi-env")
    ];

    user = "${builtins.toString UID}";
  };

  systemd.tmpfiles.rules = [
    "d /srv/wakapi 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  services.nginx.virtualHosts."waka.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://wakapi.docker:3000$request_uri";
      proxyWebsockets = true;
    };
  };
}