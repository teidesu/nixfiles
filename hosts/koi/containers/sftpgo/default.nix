{ pkgs, abs, config, ... }@inputs:

let 
  secrets = import (abs "lib/secrets.nix");

  UID = 1112;
in {
  imports = [
    (secrets.declare [{
      name = "sftpgo-env";
      owner = "sftpgo";
    }])
    ./samba.nix
  ];

  users.users.sftpgo = {
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.sftpgo = {
    image = "drakkan/sftpgo:v2.6.2";
    volumes = [
      "/srv/sftpgo/data:/srv/sftpgo"
      "/srv/sftpgo/config:/var/lib/sftpgo"
      "/mnt/puffer:/mnt/puffer"
    ];
    user = builtins.toString UID;
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
      (secrets.file config "sftpgo-env")
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/sftpgo/data 0700 ${builtins.toString UID} ${builtins.toString UID} -"
    "d /srv/sftpgo/config 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  services.nginx.virtualHosts."puffer.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://sftpgo.docker:8080$request_uri";
      proxyWebsockets = true;
    };

    locations."/dav/" = {
      proxyPass = "http://sftpgo.docker:80$request_uri";
    };
  };
}