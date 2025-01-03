{ config, ... }:


let 
  UID = 1106;
in {
  desu.secrets.bluesky-pds-secrets.owner = "bluesky-pds";

  users.groups.bluesky-pds = {};
  users.users.bluesky-pds = {
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.bluesky-pds = {
    image = "ghcr.io/bluesky-social/pds:sha-b595125a28368fa52d12d3b6ca265c1bea06977f";
    cmd = [ "node" "--enable-source-maps" "/app/entrypoint.js" ];
    volumes = [
      "${./entrypoint.js}:/app/entrypoint.js"
    ];
    environment = {
      PDS_HOSTNAME = "pds.stupid.fish";
      PDS_DATA_DIRECTORY = "/pds";
      PDS_BLOBSTORE_S3_BUCKET = "bluesky-blobstore";
      PDS_BLOBSTORE_S3_REGION = "auto";
      PDS_BLOBSTORE_S3_FORCE_PATH_STYLE = "true";
      PDS_BLOBSTORE_S3_UPLOAD_TIMEOUT_MS = "60000";
      PDS_DID_PLC_URL = "https://plc.directory";
      PDS_BSKY_APP_VIEW_URL = "https://api.bsky.app";
      PDS_BSKY_APP_VIEW_DID = "did:web:api.bsky.app";
      PDS_REPORT_SERVICE_URL = "https://mod.bsky.app";
      PDS_REPORT_SERVICE_DID = "did:plc:ar7c4by46qjdydhdevvrndac";
      PDS_CRAWLERS = "https://bsky.network,https://relay.cerulea.blue";
      LOG_ENABLED = "true";
      PDS_INVITE_REQUIRED = "true";
    };
    environmentFiles = [
      # PDS_JWT_SECRET, PDS_ADMIN_PASSWORD, PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX
      # + s3 credentials
      config.desu.secrets.bluesky-pds-secrets.path
    ];
    user = builtins.toString UID;
    extraOptions = [
      "--mount=type=bind,source=/srv/bluesky-pds/data,target=/pds"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/bluesky-pds 0700 ${builtins.toString UID} ${builtins.toString UID} -"
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

    locations."/xrpc/com.atproto.sync.getBlob" = {
      proxyPass = "http://bluesky-pds.docker:3000$request_uri";
      extraConfig = ''
        proxy_hide_header "cache-control";
        add_header "cache-control" "public, immutable, no-transform, stale-while-revalidate=31536000, max-age=31536000";
      '';
    };
  };
}
