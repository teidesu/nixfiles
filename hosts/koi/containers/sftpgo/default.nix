{ config, ... }: 

let 
  UID = 1112;
  WEBDAV_PORT = 16821;
in {
  imports = [
    ./samba.nix
  ];

  desu.secrets.sftpgo-env.owner = "sftpgo";

  users.users.sftpgo = {
    isNormalUser = true;
    uid = UID;
    extraGroups = [ "geesefs" ];
  };

  virtualisation.oci-containers.containers.sftpgo = {
    image = "drakkan/sftpgo:v2.6.2";
    user = "${builtins.toString UID}:${builtins.toString UID}";
    extraOptions = [
      "--group-add=${builtins.toString config.users.groups.geesefs.gid}"
      "--mount=type=bind,source=/srv/sftpgo/data,target=/srv/sftpgo"
      "--mount=type=bind,source=/srv/sftpgo/config,target=/var/lib/sftpgo"
      "--mount=type=bind,source=/mnt/puffer,target=/mnt/puffer"
      "--mount=type=bind,source=/mnt/s3-desu-priv-encrypted,target=/mnt/s3-desu-priv-encrypted"
    ];
    environment = {
      SFTPGO_SFTPD__BINDINGS__0__PORT = "22";
      SFTPGO_WEBDAVD__BINDINGS__0__PORT = "80";
      SFTPGO_WEBDAVD__BINDINGS__0__PROXY_ALLOWED = "172.17.0.1";
      SFTPGO_WEBDAVD__BINDINGS__0__CLIENT_IP_PROXY_HEADER = "X-Forwarded-For";
      SFTPGO_WEBDAVD__BINDINGS__0__PREFIX = "/dav/";
      SFTPGO_HTTPD__BINDINGS__0__PORT = "8080";
      SFTPGO_HTTPD__BINDINGS__0__ENABLED_LOGIN_METHODS = "3";
      SFTPGO_HTTPD__BINDINGS__0__SECURITY__ENABLED = "true";
      SFTPGO_HTTPD__BINDINGS__0__SECURITY__ALLOWED_HOSTS = "puffer.stupid.fish";
      SFTPGO_HTTPD__BINDINGS__0__BRANDING__NAME = "puffer";
      SFTPGO_HTTPD__BINDINGS__0__BRANDING__SHORT_NAME = "puffer";
      SFTPGO_HTTPD__BINDINGS__0__OIDC__REDIRECT_BASE_URL = "https://puffer.stupid.fish/";
      SFTPGO_HTTPD__BINDINGS__0__OIDC__USERNAME_FIELD = "preferred_username";
      SFTPGO_HTTPD__BINDINGS__0__OIDC__IMPLICIT_ROLES = "true";
    };
    environmentFiles = [
      config.desu.secrets.sftpgo-env.path
    ];
    ports = [
      "${builtins.toString WEBDAV_PORT}:80"
    ];
  };
  systemd.services.docker-sftpgo.requires = [ "gocryptfs.service" ];

  systemd.tmpfiles.rules = [
    "d /srv/sftpgo/data 0700 ${builtins.toString UID} ${builtins.toString UID} -"
    "d /srv/sftpgo/config 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  services.nginx.virtualHosts = {
    "puffer.stupid.fish" = {
      forceSSL = true;
      useACMEHost = "stupid.fish";

      extraConfig = ''
        client_max_body_size 25G;
      '';

      locations."/" = {
        proxyPass = "http://sftpgo.docker:8080$request_uri";
        proxyWebsockets = true;
      };

      locations."/dav/" = {
        proxyPass = "http://sftpgo.docker:80$request_uri";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ WEBDAV_PORT ];

  services.avahi.extraServiceFiles.puffer-lan = ''
    <?xml version="1.0" standalone='no'?>
    <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
    <service-group>
      <name>puffer-lan</name>
      <service>
        <port>${builtins.toString WEBDAV_PORT}</port>
        <type>_webdav._tcp</type>
        <txt-record>path=/dav/</txt-record>
      </service>
    </service-group>
  '';
}