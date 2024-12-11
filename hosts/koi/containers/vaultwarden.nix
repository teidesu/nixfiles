{ config, ... }:

let
  UID = 1109;
in {
  desu.secrets.vaultwarden-env.owner = "vaultwarden";

  virtualisation.oci-containers.containers.vaultwarden = {
    image = "vaultwarden/server:1.32.5-alpine";
    environment = {
      SIGNUPS_ALLOWED = "false";
      DOMAIN = "https://bw.tei.su";
      WEBSOCKET_ENABLED = "true";
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = "80";
      EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "ssh-key-vault-item,ssh-agent,extension-refresh";
    };
    environmentFiles = [
      config.desu.secrets.vaultwarden-env.path
    ];
    user = builtins.toString UID;
    extraOptions = [
      "--mount=type=bind,source=/srv/vaultwarden,target=/data"
    ];
  };

  users.users.vaultwarden = {
    isNormalUser = true;
    uid = UID;
  };

  systemd.tmpfiles.rules = [
    "d /srv/vaultwarden 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  services.nginx.virtualHosts."bw.tei.su" = {
    forceSSL = true;
    useACMEHost = "tei.su";

    locations."/" = {
      proxyPass = "http://vaultwarden.docker$request_uri";
      proxyWebsockets = true;
    };
  };
}