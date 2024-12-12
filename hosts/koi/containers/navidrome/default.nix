{ config, pkgs, ... }:

let 
  UID = 1102;

  feishin = pkgs.callPackage ./feishin.nix {};
  feishinConfig = builtins.replaceStrings [ "\n" ] [ "" ] ''
    window.SERVER_URL="https://navi.stupid.fish";
    window.SERVER_NAME="stupid.fish";
    window.SERVER_TYPE="navidrome";
    window.SERVER_LOCK=true;
    const style = document.createElement("style");
    style.innerHTML = `
      #sidebar-queue .mantine-Stack-root:has([class^=TitleWrapper]) { display: none; }
    `;
    document.head.appendChild(style);
  '';
in {
  desu.secrets.navidrome-env.owner = "navidrome";

  users.users.navidrome = {
    isNormalUser = true;
    uid = UID;
    extraGroups = [ "geesefs" ];
  };

  virtualisation.oci-containers.containers.navidrome = {
    image = "deluan/navidrome:0.53.3";
    volumes = [
      "${./navidrome.toml}:/navidrome.toml"
    ];
    environment = {
      ND_CONFIGFILE = "/navidrome.toml";
    };
    environmentFiles = [
      config.desu.secrets.navidrome-env.path
    ];
    user = "${builtins.toString UID}:${builtins.toString UID}";
    extraOptions = [
      "--group-add=${builtins.toString config.users.groups.geesefs.gid}"
      "--mount=type=bind,source=/mnt/s3-desu-priv-encrypted/music,target=/music/s3,readonly"
      "--mount=type=bind,source=/srv/navidrome,target=/data"
    ];
  };
  systemd.services.docker-navidrome.requires = [ "gocryptfs.service" ];

  systemd.tmpfiles.rules = [
    "d /srv/navidrome 0755 ${builtins.toString UID} ${builtins.toString UID} -"
  ];

  services.nginx.virtualHosts."navi.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://navidrome.docker:4533$request_uri";

      extraConfig = ''
        proxy_buffering off;
      '';
    };

    locations."/feishin/" = {
      extraConfig = ''
        alias ${feishin}/;
        try_files $uri $uri/ /index.html;
      '';
    };

    locations."/feishin/settings.js" = {
      extraConfig = ''
        add_header 'Content-Type' 'application/javascript';
        return 200 '${feishinConfig}';
      '';
    };
  };
}