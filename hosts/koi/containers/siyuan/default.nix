{ pkgs, ... }:

let 
  UID = 1113;
  context = pkgs.copyPathToStore ./image;
in {
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
    cmd = [ "--workspace=/data" ];
    environment = {
      # we manage auth via openid-proxy
      SIYUAN_ACCESS_AUTH_CODE_BYPASS = "true";
    };
    user = builtins.toString UID;
    extraOptions = [
      "--mount=type=bind,source=/srv/siyuan-teidesu,target=/data"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/siyuan-teidesu 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  desu.secrets.siyuan-teidesu-proxy-env.owner = "siyuan-teidesu";
  desu.openid-proxy.services.siyuan-teidesu = {
    clientId = "teidesu-siyuan";
    domain = "siyuan.tei.su";
    upstream = "http://siyuan-teidesu.docker:6806";
    envSecret = "siyuan-teidesu-proxy-env";
    uid = UID;
  };

  services.nginx.virtualHosts."siyuan.tei.su" = {
    forceSSL = true;
    useACMEHost = "tei.su";

    locations."/" = {
      proxyPass = "http://siyuan-teidesu-oidc.docker$request_uri";
      proxyWebsockets = true;
    };
  };
}