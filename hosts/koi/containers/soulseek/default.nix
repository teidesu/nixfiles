{ config, ... }: 

let 
  UID = 1119;
in {
  users.users.soulseek = {
    isNormalUser = true;
    uid = UID;
    extraGroups = [ "geesefs" ];
  };

  systemd.services.docker-slskd.requires = [ "gocryptfs.service" ];
  virtualisation.oci-containers.containers.slskd = {
    image = "slskd/slskd:0.21.4.65534-9a68c184";
    volumes = [
      "/srv/slskd:/app"
      "/mnt/s3-desu-priv-encrypted/music:/mnt/music"
      "/mnt/puffer/Downloads:/mnt/downloads"
    ];

    ports = [
      "50300:50300"
    ];

    environment = {
      SLSKD_REMOTE_CONFIGURATION = "true";
      SLSKD_DOWNLOADS_DIR = "/mnt/downloads";
      SLSKD_REMOTE_FILE_MANAGEMENT = "true";
      SLSKD_SHARED_DIR = "/mnt/music";
      SLSKD_NO_HTTPS = "true";
      SLSKD_NO_AUTH = "true"; # managed by oidc proxy
    };

    user = "${builtins.toString UID}:${builtins.toString UID}";
    extraOptions = [
      "--group-add=${builtins.toString config.users.groups.geesefs.gid}"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/slskd 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  desu.openid-proxy.services.soulseek = {
    clientId = "torrent";
    domain = "soulseek.stupid.fish";
    upstream = "http://slskd.docker:5030";
    envSecret = "torrent-proxy-env";
  };

  services.nginx.virtualHosts."soulseek.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://soulseek-oidc.docker$request_uri";
      proxyWebsockets = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 50300 ];
}