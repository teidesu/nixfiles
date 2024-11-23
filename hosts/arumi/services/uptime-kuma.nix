{ config, ... }:

let 
  UID = 1100;
in {
  # we use cf tunnels because 443 port is used by the proxy,
  # and it's also generally easier

  desu.secrets.arumi-cf-token.owner = "uptime-kuma";

  users.users.uptime-kuma = {
    isNormalUser = true;
    uid = UID;
  };
  users.groups.uptime-kuma = {};

  virtualisation.oci-containers.containers.uptime-kuma = {
    image = "louislam/uptime-kuma:1.23.13-debian";
    volumes = [
      "/srv/uptime-kuma:/app/data"
    ];
    environment = {
      PUID = builtins.toString UID;
      PGID = builtins.toString UID;
    };
    environmentFiles = [
      config.desu.secrets.arumi-cf-token.path
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/uptime-kuma 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];
}