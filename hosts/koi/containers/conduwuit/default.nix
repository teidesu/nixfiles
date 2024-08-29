{ abs, config, ... } @ inputs:

let 
  secrets = import (abs "lib/secrets.nix");

  UID = 1107;
in {
  imports = [
    (secrets.declare [{
      name = "conduwuit-env";
      owner = "conduwuit";
    }])
    ./bridges/telegram
  ];

  users.groups.conduwuit = {};
  users.users.conduwuit = {
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.conduwuit = {
    image = "ghcr.io/girlbossceo/conduwuit:main-28cd784972f9e6e78a77ee54ca07d998ca15a788";
    volumes = [
      "${./config.toml}:/conduwuit.toml"
      "/srv/conduwuit:/data"
    ];
    environment = {
      CONDUWUIT_CONFIG = "/conduwuit.toml";
    };
    environmentFiles = [
      (secrets.file config "conduwuit-env")
    ];
    user = builtins.toString UID;
  };

  systemd.tmpfiles.rules = [
    "d /srv/conduwuit 0755 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  services.nginx.virtualHosts."stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/_matrix/" = {
      proxyPass = "http://conduwuit.docker:6167$request_uri";

      extraConfig = ''
        proxy_buffering off;
      '';
    };

    locations."/.well-known/matrix/server" = {
      extraConfig = ''
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Content-Type' 'application/json';
        return 200 '{"m.server": "stupid.fish:443"}';
      '';
    };
  };
}