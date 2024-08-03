{ abs, pkgs, lib, config, ... }@inputs:

let
  containers = import (abs "lib/containers.nix") inputs;
  secrets = import (abs "lib/secrets.nix");

  env = secrets.mount config "vaultwarden-env";
in {
  imports = [
    (secrets.declare [ "vaultwarden-env" ])
    (containers.mkNixosContainer {
      name = "vault";
      ip = ".0.7";
      private = true;

      config = { ... }: {
        services.vaultwarden = {
          enable = true;
          config = {
            SIGNUPS_ALLOWED = false;
            DOMAIN = "https://bw.tei.su";
            WEBSOCKET_ENABLED = true;
            ROCKET_ADDRESS = "0.0.0.0";
            ROCKET_PORT = 80;
            DATA_FOLDER = "/mnt/vault/data";
          };
          environmentFile = env.path;
        };

        systemd.services.vaultwarden.serviceConfig = {
          ReadWritePaths = [ "/mnt/vault" ];
        };

        networking.firewall.allowedTCPPorts = [ 80 ];
      };

      mounts = {
        "/mnt/vault" = {
          hostPath = "/mnt/puffer/vaultwarden-vault";
          isReadOnly = false;
        };
      } // (env.mounts);
    })
  ];

  services.nginx.virtualHosts."bw.tei.su" = {
    forceSSL = true;
    useACMEHost = "tei.su";

    locations."/" = {
      proxyPass = "http://vault.containers$request_uri";
      proxyWebsockets = true;
    };
  };
}