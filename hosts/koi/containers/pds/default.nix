{ abs, config, pkgs, ... }@inputs:


let 
  secrets = import (abs "lib/secrets.nix");
in {
  imports = [
    (secrets.declare [
      "bluesky-pds-secrets"
    ])
    ((import (abs "lib/containers.nix") inputs).mkDockerComposeContainer {
      directory = ./.;
      envFiles = [
        # PDS_JWT_SECRET, PDS_ADMIN_PASSWORD, PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX, PDS_EMAIL_SMTP_URL
        (secrets.file config "bluesky-pds-secrets")
      ];
    })
  ];

  systemd.tmpfiles.rules = [
    "d /mnt/puffer/bluesky-pds 0777 root root -"
    "d /srv/bluesky-pds/data 0777 root root -"
  ];

  services.nginx.virtualHosts."pds.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";
    http2 = true;

    extraConfig = ''
      client_max_body_size 250M;
    '';
    
    locations."/" = {
      proxyPass = "http://pds.pds.docker:3000/";
      proxyWebsockets = true;
    };
  };
}
