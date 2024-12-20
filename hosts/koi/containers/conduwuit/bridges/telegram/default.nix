{ pkgs, abs, config, ... } @ inputs:

let 
  env = import (abs "lib/env.nix") inputs;

  UID = 1108;

  bridgeConfig = pkgs.writeText "config.yaml" (builtins.toJSON (import ./config.nix));
in {
  desu.secrets.mautrix-tg-env.owner = "mautrix";

  users.groups.mautrix = {};
  users.users.mautrix = {
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.mautrix-telegram = let 
    entrypoint = env.mkJsonEnvEntrypoint {
      template = "/config-template.yaml";
      target = "/data/config.yaml";
      entrypoint = "python3 -m mautrix_telegram -c /data/config.yaml";
    };
  in {
    image = "dock.mau.dev/mautrix/telegram:v0.15.2";
    volumes = [
      "${bridgeConfig}:/config-template.yaml:ro"
      "${pkgs.pkgsStatic.jq}/bin/jq:/bin/jq"
      "${entrypoint}:/entrypoint.sh"
    ];
    environment = {
      MAUTRIX_DIRECT_STARTUP = "1";
    };
    entrypoint = "/entrypoint.sh";
    environmentFiles = [
      config.desu.secrets.mautrix-tg-env.path
    ];
    user = builtins.toString UID;
    extraOptions = [
      "--mount=type=bind,source=/srv/mautrix-telegram,target=/data"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/mautrix-telegram 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];
}