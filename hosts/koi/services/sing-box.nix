{ pkgs, abs, config, ... }:

let
  secrets = import (abs "lib/secrets.nix");
  secretsUnsafe = pkgs.callPackage (abs "lib/secrets-unsafe.nix") {};
in {
  imports = [
    (secrets.declare [ 
      "arumi-singbox-pub"
      "arumi-singbox-sid"
      "arumi-singbox-koi-uuid"
      "vless-sakura-ip"
      "vless-sakura-pk"
      "vless-sakura-sid"
      "vless-sakura-uuid"
    ])
  ];

  services.sing-box = {
    enable = true;
    settings = {
      log.level = "warning";

      inbounds = [
        {
          tag = "mixed-in";
          type = "mixed";
          listen = "0.0.0.0";
          listen_port = 7890;
        }
      ];

      outbounds = [
        { tag = "direct"; type = "direct"; }
        {
          tag = "xtls-arumi";
          type = "vless";
          flow = "xtls-rprx-vision";
          server = secretsUnsafe.readUnsafe "arumi-ip";
          server_port = 443;
          domain_strategy = "";
          packet_encoding = "";
          tls = {
            enabled = true;
            alpn = [ "h2" ];
            server_name = "updates.cdn-apple.com";
            reality = {
              enabled = true;
              public_key._secret = secrets.file config "arumi-singbox-pub";
              short_id._secret = secrets.file config "arumi-singbox-sid";
            };
            utls = { enabled = true; fingerprint = "edge"; };
          };
          uuid._secret = secrets.file config "arumi-singbox-koi-uuid";
        }
        {
          # thanks kamillaova
          tag = "xtls-sakura";
          flow = "xtls-rprx-vision";
          server._secret = secrets.file config "vless-sakura-ip";
          server_port = 443;
          tls = {
            alpn = [ "h2" ];
            enabled = true;
            reality = {
              enabled = true;
              public_key._secret = secrets.file config "vless-sakura-pk";
              short_id._secret = secrets.file config "vless-sakura-sid";
            };
            server_name = "telegram.org";
            utls = { enabled = true; fingerprint = "edge"; };
          };
          type = "vless";
          uuid._secret = secrets.file config "vless-sakura-uuid";
        }
        {
          tag = "final";
          type = "urltest";
          outbounds = [
            "xtls-arumi"
            "xtls-sakura"
          ];
        }
      ];

      route.final = "final";
    };
  };

  networking.firewall.allowedTCPPorts = [ 7890 ];
}
