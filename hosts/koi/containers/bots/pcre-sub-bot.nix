{ abs, config, ... }:

let 
  secrets = import (abs "lib/secrets.nix");

  UID = 1101;
in {
  imports = [
    (secrets.declare [{
      name = "pcresub-bot-env";
      owner = "pcre-sub-bot";
    }])
  ];

  users.groups.pcre-sub-bot = {};
  users.users.pcre-sub-bot = {
    group = "pcre-sub-bot";
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.pcre-sub-bot = {
    image = "ghcr.io/teidesu/pcre-sub-bot:sha-d010ea7@sha256:d30a1adf852f1953bb4015d55f0031a41bd65657abc4880ecd1dfcb67a77a678";
    volumes = [
      "/srv/pcre-sub-bot:/app/bot-data"
    ];
    environmentFiles = [
      (secrets.file config "pcresub-bot-env")
    ];
    user = builtins.toString UID;
  };

  systemd.tmpfiles.rules = [
    "d /srv/pcre-sub-bot 0777 pcre-sub-bot pcre-sub-bot -"
  ];
}