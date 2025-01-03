{ abs, pkgs, config, ... }@inputs:

let 
  UID = 1114;
in {
  users.users.memos = {
    isNormalUser = true;
    uid = UID;
  };

  services.postgresql.ensureUsers = [
    { name = "memos"; ensureDBOwnership = true; }
  ];
  services.postgresql.ensureDatabases = [ "memos" ];
  desu.postgresql.ensurePasswords.memos = "memos";

  systemd.services.docker-memos.after = [ "postgresql.service" ];
  virtualisation.oci-containers.containers.memos = {
    image = "neosmemo/memos:0.22.5";

    environment = {
      MEMOS_DRIVER = "postgres";
      MEMOS_DSN = "postgresql://memos:memos@172.17.0.1:5432/memos?sslmode=disable";
    };
    
    user = "${builtins.toString UID}";

    extraOptions = [
      "--mount=type=bind,source=/srv/memos/data,target=/var/opt/memos"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/memos/data 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  services.nginx.virtualHosts."lore.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://memos.docker:5230$request_uri";
      proxyWebsockets = true;
    };
  };
}