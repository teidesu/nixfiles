{ abs, config, ... }:

let 
  secrets = import (abs "lib/secrets.nix");

  UID = 1105;
in {
  imports = [
    (secrets.declare [{
      name = "channel-logger-bot-env";
      owner = "channel-logger-bot";
    }])
  ];

  users.groups.channel-logger-bot = {};
  users.users.channel-logger-bot = {
    group = "channel-logger-bot";
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.channel-logger-bot = {
    image = "ghcr.io/teidesu/channel-logger-bot:latest";
    volumes = [
      "/srv/channel-logger-bot:/app/bot-data"
    ];
    environmentFiles = [
      (secrets.file config "channel-logger-bot-env")
    ];
    environment.MTCUTE_LOG_LEVEL = "5";
    user = builtins.toString UID;
  };

  systemd.tmpfiles.rules = [
    "d /srv/channel-logger-bot 0755 ${builtins.toString UID} ${builtins.toString UID} -"
  ];
}