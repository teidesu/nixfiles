{ abs, pkgs, config, ... }@inputs:

let
  secrets = import (abs "lib/secrets.nix");

  UID = 1109;
in {
  imports = [
    (secrets.declare [{
      name = "vaultwarden-env";
      owner = "vaultwarden";
    }])
  ];

  virtualisation.oci-containers.containers.vaultwarden = {
    image = "vaultwarden/server:1.32.0";
    volumes = [
      "/srv/vaultwarden:/data"
    ];
    environment = {
      SIGNUPS_ALLOWED = "false";
      DOMAIN = "https://bw.tei.su";
      WEBSOCKET_ENABLED = "true";
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = "80";
    };
    environmentFiles = [
      (secrets.file config "vaultwarden-env")
    ];
    user = builtins.toString UID;
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