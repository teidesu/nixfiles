{ pkgs, abs, config, ... }:

let
  secrets = import (abs "lib/secrets.nix");
  secretsUnsafe = pkgs.callPackage (abs "lib/secrets-unsafe.nix") {};
in {
  imports = [
    (secrets.declare [ 
      "madohomu-singbox-pub"
      "madohomu-singbox-sid"
      "madohomu-singbox-koi-uuid"
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
          tag = "xtls-madoka";
          type = "vless";
          flow = "xtls-rprx-vision";
          server = secretsUnsafe.readUnsafe "madoka-ip";
          server_port = 443;
          domain_strategy = "";
          packet_encoding = "";
          tls = {
            enabled = true;
            alpn = [ "h2" ];
            server_name = "updates.cdn-apple.com";
            reality = {
              enabled = true;
              public_key._secret = secrets.file config "madohomu-singbox-pub";
              short_id._secret = secrets.file config "madohomu-singbox-sid";
            };
            utls = { enabled = true; fingerprint = "edge"; };
          };
          uuid._secret = secrets.file config "madohomu-singbox-koi-uuid";
        }
        {
          tag = "xtls-homura";
          type = "vless";
          flow = "xtls-rprx-vision";
          server = secretsUnsafe.readUnsafe "homura-ip";
          server_port = 443;
          domain_strategy = "";
          packet_encoding = "";
          tls = {
            enabled = true;
            alpn = [ "h2" ];
            server_name = "updates.cdn-apple.com";
            reality = {
              enabled = true;
              public_key._secret = secrets.file config "madohomu-singbox-pub";
              short_id._secret = secrets.file config "madohomu-singbox-sid";
            };
            utls = { enabled = true; fingerprint = "edge"; };
          };
          uuid._secret = secrets.file config "madohomu-singbox-koi-uuid";
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
            "xtls-sakura"
            "xtls-madoka"
            "xtls-homura"
          ];
        }
      ];

      route.final = "final";
    };
  };

  networking.firewall.allowedTCPPorts = [ 7890 ];
}
