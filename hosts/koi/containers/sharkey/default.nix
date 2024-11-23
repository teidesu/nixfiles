{ pkgs, ... }:

let 
  UID = 1104;
  context = pkgs.copyPathToStore ./.;
in {
  users.users.misskey = {
    isNormalUser = true;
    uid = UID;
  };

  systemd.tmpfiles.rules = [
    "d /srv/Sharkey 0777 root root -"
  ];

  services.postgresql.ensureUsers = [
    { name = "misskey"; ensureDBOwnership = true; }
  ];
  services.postgresql.ensureDatabases = [ "misskey" ];
  desu.postgresql.ensurePasswords.misskey = "misskey";

  virtualisation.oci-containers.containers.sharkey-redis = {
    image = "docker.io/redis:7.0-alpine";
    volumes = [
      "/srv/Sharkey/redis:/data"
    ];
    user = builtins.toString UID;
  };
  
  virtualisation.oci-containers.containers.sharkey-meili = {
    image = "getmeili/meilisearch:v1.3.4";
    volumes = [
      "/srv/Sharkey/meili_data:/meili_data"
    ];
    environment = {
      MEILI_NO_ANALYTICS = "true";
      MEILI_ENV = "production";
      MEILI_MASTER_KEY = "misskeymeilisearch";
    };
    user = builtins.toString UID;
  };

  # not really reproducible but fuck it i figured it's the best way lol. 
  # im **not** rewriting that 100 lines dockerfile
  systemd.services.docker-sharkey.serviceConfig.ExecStartPre = [
    (pkgs.writeShellScript "build-sharkey" ''
      docker build -t local/sharkey ${context}
    '')
  ];
  systemd.services.docker-sharkey.after = [ "postgresql.service" ];
  virtualisation.oci-containers.containers.sharkey = {
    dependsOn = [ "sharkey-redis" "sharkey-meili" ];
    image = "local/sharkey";
    volumes = [
      "/srv/Sharkey/files:/sharkey/files"
      "${context}/.config:/sharkey/.config:ro"
    ];
    environment = {
      NODE_ENV = "production";
    };
    user = builtins.toString UID;
  };

  services.nginx.virtualHosts."very.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";
    http2 = true;

    extraConfig = ''
      client_max_body_size 250M;
    '';
    
    locations."/" = {
      proxyPass = "http://sharkey.docker$request_uri";
      proxyWebsockets = true;
    };
  };
}
