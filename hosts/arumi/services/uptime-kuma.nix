{ abs, config, ... }:

let 
  secrets = import (abs "lib/secrets.nix");

  UID = 1100;
in {
  # we use cf tunnels because 443 port is used by the proxy,
  # and it's also generally easierbrew install cloudflared && 

  imports = [
    (secrets.declare [{
      name = "arumi-cf-token";
      owner = "uptime-kuma";
    }])
  ];

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
      (secrets.file config "arumi-cf-token")
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/uptime-kuma 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];
}