{ config, ... }:

let 
  UID = 1105;
in {
  desu.secrets.channel-logger-bot-env.owner = "channel-logger-bot";

  users.groups.channel-logger-bot = {};
  users.users.channel-logger-bot = {
    group = "channel-logger-bot";
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.channel-logger-bot = {
    image = "ghcr.io/teidesu/channel-logger-bot:latest";
    environmentFiles = [
      config.desu.secrets.channel-logger-bot-env.path
    ];
    environment.MTCUTE_LOG_LEVEL = "5";
    user = builtins.toString UID;
    extraOptions = [
      "--mount=type=bind,source=/srv/channel-logger-bot,target=/app/bot-data"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/channel-logger-bot 0755 ${builtins.toString UID} ${builtins.toString UID} -"
  ];
}