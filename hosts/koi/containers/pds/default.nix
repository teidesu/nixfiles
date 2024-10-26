{ abs, config, pkgs, ... }@inputs:


let 
  secrets = import (abs "lib/secrets.nix");

  UID = 1106;
in {
  imports = [
    (secrets.declare [{
      name = "bluesky-pds-secrets";
      owner = "bluesky-pds";
    }])
  ];

  users.groups.bluesky-pds = {};
  users.users.bluesky-pds = {
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.bluesky-pds = {
    image = "ghcr.io/bluesky-social/pds:sha-94a80820872510e65cb8e62e5a78aa6a8d9ad6c9";
    volumes = [
      "/srv/bluesky-pds/data:/pds"
      "/mnt/puffer/bluesky-pds:/blobstore"
    ];
    environment = {
      PDS_HOSTNAME = "pds.stupid.fish";
      PDS_DATA_DIRECTORY = "/pds";
      PDS_BLOBSTORE_DISK_LOCATION = "/blobstore";
      PDS_DID_PLC_URL = "https://plc.directory";
      PDS_BSKY_APP_VIEW_URL = "https://api.bsky.app";
      PDS_BSKY_APP_VIEW_DID = "did:web:api.bsky.app";
      PDS_REPORT_SERVICE_URL = "https://mod.bsky.app";
      PDS_REPORT_SERVICE_DID = "did:plc:ar7c4by46qjdydhdevvrndac";
      PDS_CRAWLERS = "https://bsky.network";
      LOG_ENABLED = "true";
      PDS_INVITE_REQUIRED = "true";
    };
    environmentFiles = [
      # PDS_JWT_SECRET, PDS_ADMIN_PASSWORD, PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX
      (secrets.file config "bluesky-pds-secrets")
    ];
    user = builtins.toString UID;
  };

  systemd.tmpfiles.rules = [
    "d /mnt/puffer/bluesky-pds 0700 ${builtins.toString UID} ${builtins.toString UID} -"
    "d /srv/bluesky-pds/data 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  services.nginx.virtualHosts."pds.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";
    http2 = true;

    extraConfig = ''
      client_max_body_size 250M;
    '';
    
    locations."/" = {
      proxyPass = "http://bluesky-pds.docker:3000$request_uri";
      proxyWebsockets = true;
    };
  };
}
