{ config, ... }: 

let 
  UID = 1115;
in {
  desu.secrets.wakapi-env.owner = "wakapi";
  desu.secrets.wakapi-proxy-env.owner = "wakapi";

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
      WAKAPI_DISABLE_FRONTPAGE = "true";
      WAKAPI_MAIL_ENABLED = "true";
      WAKAPI_MAIL_SENDER = "waka.stupid.fish <noreply@stupid.fish>";
      WAKAPI_AVATAR_URL_TEMPLATE = "https://t.me/i/userpic/320/{username}.jpg";
      WAKAPI_SUPPORT_CONTACT = "alina@tei.su";

      WAKAPI_TRUSTED_HEADER_AUTH = "true";
      WAKAPI_TRUSTED_HEADER_AUTH_KEY = "X-Forwarded-Preferred-Username";
      WAKAPI_TRUST_REVERSE_PROXY_IPS = "172.17.0.0/16";
    };

    environmentFiles = [
      config.desu.secrets.wakapi-env.path
    ];

    user = "${builtins.toString UID}";
  };

  desu.openid-proxy.services.wakapi = {
    clientId = "300318162728058886";
    domain = "waka.stupid.fish";
    upstream = "http://wakapi.docker:3000";
    envSecret = "wakapi-proxy-env";
    uid = UID;
    extra = [
      "--skip-auth-route=POST=^/((v1/)?users/[^/]+/)?heartbeat(s|s\.bulk)?$"
      "--skip-auth-route=^/api/"
    ];
  };

  services.nginx.virtualHosts."waka.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://wakapi-oidc.docker$request_uri";
      proxyWebsockets = true;
    };
  };
}