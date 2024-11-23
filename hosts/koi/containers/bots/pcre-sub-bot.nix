{ config, ... }:

let 
  UID = 1101;
in {
  desu.secrets.pcresub-bot-env.owner = "pcre-sub-bot";

  users.groups.pcre-sub-bot = {};
  users.users.pcre-sub-bot = {
    group = "pcre-sub-bot";
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.pcre-sub-bot = {
    image = "ghcr.io/teidesu/pcre-sub-bot:latest";
    volumes = [
      "/srv/pcre-sub-bot:/app/bot-data"
    ];
    environmentFiles = [
      config.desu.secrets.pcresub-bot-env.path
    ];
    user = builtins.toString UID;
  };

  systemd.tmpfiles.rules = [
    "d /srv/pcre-sub-bot 0777 pcre-sub-bot pcre-sub-bot -"
  ];
}