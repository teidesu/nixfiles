{ abs, pkgs, config, ... }@inputs:

let 
  secrets = import (abs "lib/secrets.nix");
  trivial = import (abs "lib/trivial.nix") inputs;

  UID = 1113;
  context = trivial.storeDirectory ./image;
in {
  imports = [
    (secrets.declare [{
      name = "siyuan-teidesu-authentik-env";
      owner = "siyuan-teidesu";
    }])
  ];
  users.users.siyuan-teidesu = {
    isNormalUser = true;
    uid = UID;
  };

  systemd.services.docker-siyuan-teidesu.serviceConfig.ExecStartPre = [
    (pkgs.writeShellScript "build-siyuan" ''
      docker build -t local/siyuan ${context}
    '')
  ];
  virtualisation.oci-containers.containers.siyuan-teidesu = {
    image = "local/siyuan";
    volumes = [
      "/srv/siyuan-teidesu:/data"
    ];
    cmd = [ "--workspace=/data" ];
    environment = {
      # we manage auth via authentik
      SIYUAN_ACCESS_AUTH_CODE_BYPASS = "true";
    };
    user = builtins.toString UID;
  };

  virtualisation.oci-containers.containers.siyuan-teidesu-authentik = {
    image = "ghcr.io/goauthentik/proxy";
    environment = {
      AUTHENTIK_HOST = "https://id.stupid.fish";
    };
    user = builtins.toString UID;
    environmentFiles = [
      (secrets.file config "siyuan-teidesu-authentik-env")
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/siyuan-teidesu 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  services.nginx.virtualHosts."siyuan.tei.su" = {
    forceSSL = true;
    useACMEHost = "tei.su";

    locations."/" = {
      proxyPass = "http://siyuan-teidesu-authentik.docker:9000$request_uri";
      proxyWebsockets = true;
    };
  };
}