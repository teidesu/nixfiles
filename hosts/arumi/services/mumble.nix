{ config, ... }:

let 
  UID = 1101;
in {
  desu.secrets.arumi-mumble-env.owner = "mumble";

  users.users.mumble = {
    isNormalUser = true;
    uid = UID;
  };
  users.groups.mumble = {};

  virtualisation.oci-containers.containers.mumble = {
    image = "mumblevoip/mumble-server:v1.5.634-0";
    volumes = [
      "/srv/mumble:/data"
    ];
    environment = {
      MUMBLE_CONFIG_WELCOME_TEXT = "";
      MUMBLE_CONFIG_ALLOW_HTML = "true";
      MUMBLE_CONFIG_LOG_ACL_CHANGES = "true";
    };
    ports = [
      "64738:64738/tcp"
      "64738:64738/udp"
    ];
    environmentFiles = [
      config.desu.secrets.arumi-mumble-env.path
    ];
    user = builtins.toString UID;
  };

  networking.firewall.allowedTCPPorts = [ 64738 ];
  networking.firewall.allowedUDPPorts = [ 64738 ];

  systemd.tmpfiles.rules = [
    "d /srv/mumble 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];
}