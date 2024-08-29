{ pkgs, abs, config, ... } @ inputs:

let 
  secrets = import (abs "lib/secrets.nix");
  trivial = import (abs "lib/trivial.nix") inputs;
  env = import (abs "lib/env.nix") inputs;

  UID = 1108;

  bridgeConfig = pkgs.writeText "config.yaml" (builtins.toJSON (import ./config.nix));
in {
  imports = [
    (secrets.declare [{
      name = "mautrix-tg-env";
      owner = "mautrix";
    }])
  ];

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
      "/srv/mautrix-telegram:/data"
    ];
    environment = {
      MAUTRIX_DIRECT_STARTUP = "1";
    };
    entrypoint = "/entrypoint.sh";
    environmentFiles = [
      (secrets.file config "mautrix-tg-env")
    ];
    user = builtins.toString UID;
  };

  systemd.tmpfiles.rules = [
    "d /srv/mautrix-telegram 0700 ${builtins.toString UID} ${builtins.toString UID} -"
  ];
}