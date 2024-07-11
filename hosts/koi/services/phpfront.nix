{ pkgs, lib, config, ... }:

{
  services.phpfpm.pools.phpfront = {
    user = "phpfront";
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
    phpOptions = ''
      short_open_tag = On
    '';
    phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
  };

  services.nginx.virtualHosts."tei.su" = {
    forceSSL = true;
    useACMEHost = "tei.su";

    root = "/srv/phpfront"; # outside flake for now, todo
    extraConfig = ''
      index index.html index.php;
    '';

    locations."/.well-known/" = {
      extraConfig = ''
        add_header 'Access-Control-Allow-Origin' '*';
      '';
    };

    locations."/_secure/" = {
      # too lazy to migrate old logic for now, just error out
      extraConfig = "return 403;";
    };
    
    # todo: nixify and open-source teidesu-api
    locations."/api/".extraConfig = ''
      proxy_pass http://localhost:8728/;
    '';

    locations."/" = {
      extraConfig = ''
        try_files $uri $uri/ =404;

        rewrite ^/?(\$|donate)$ /donate.php;
        rewrite ^/ava320.jpg$ /ava320.php;
        rewrite ^/pfrepl https://teidesu.github.io/protoflex/repl redirect;
        rewrite ^/im\.mp3 https://vk.com/mp3/cc_ice_melts.mp3 redirect;
      '';
    };

    locations."~ \\.php$ " = {
      extraConfig = ''
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:${config.services.phpfpm.pools.phpfront.socket};
        fastcgi_index index.php;
        include ${pkgs.nginx}/conf/fastcgi.conf;
      '';
    };
  };

  users.users.phpfront = {
    isSystemUser = true;
    createHome = true;
    home = "/srv/phpfront";
    group  = "phpfront";
  };
  users.groups.phpfront = {};
}