{ abs, config, ... } @ inputs:

let 
  secrets = import (abs "lib/secrets.nix");

  UID = 1102;
in {
  imports = [
    (secrets.declare [{
      name = "navidrome-env";
      owner = "navidrome";
    }])
  ];

  users.groups.navidrome = {};
  users.users.navidrome = {
    isNormalUser = true;
    uid = UID;
  };

  virtualisation.oci-containers.containers.navidrome = {
    image = "deluan/navidrome:0.52.5@sha256:b154aebe8b33bae82c500ad0a3eb743e31da54c3bfb4e7cc3054b9a919b685c7";
    volumes = [
      "${./navidrome.toml}:/navidrome.toml"
      "/mnt/puffer/Downloads/music:/music:ro"
      "/mnt/puffer/navidrome:/data"
    ];
    environment = {
      ND_CONFIGFILE = "/navidrome.toml";
    };
    environmentFiles = [
      (secrets.file config "navidrome-env")
    ];
    user = builtins.toString UID;
  };

  systemd.tmpfiles.rules = [
    "d /mnt/puffer/navidrome 0755 navidrome navidrome  -"
  ];

  services.nginx.virtualHosts."navi.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://navidrome.docker:4533/";

      extraConfig = ''
        proxy_buffering off;
      '';
    };
  };
}