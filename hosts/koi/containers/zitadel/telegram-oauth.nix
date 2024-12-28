{ config, ... }:

let 
  UID = 1123;
in {
  desu.secrets.telegram-oauth-env.owner = "telegram-oauth";

  users.groups.telegram-oauth = {};
  users.users.telegram-oauth = {
    group = "telegram-oauth";
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.telegram-oauth = {
    image = "ghcr.io/teidesu/telegram-oauth:latest";
    environment = {
      PUBLIC_URL = "https://tgauth.stupid.fish";
      REDIRECT_URL = "https://id.stupid.fish/ui/login/login/externalidp/callback";
    };
    environmentFiles = [
      config.desu.secrets.telegram-oauth-env.path
    ];
    user = builtins.toString UID;
    extraOptions = [
      "--mount=type=bind,source=/srv/telegram-oauth,target=/app/data"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/telegram-oauth 700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  services.nginx.virtualHosts."tgauth.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://telegram-oauth.docker:3000$request_uri";
    };
  };
}