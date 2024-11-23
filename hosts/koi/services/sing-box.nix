{ config, ... }:

{

  desu.secrets.arumi-singbox-pub = {};
  desu.secrets.arumi-singbox-sid = {};
  desu.secrets.arumi-singbox-koi-uuid = {};
  desu.secrets.vless-sakura-ip = {};
  desu.secrets.vless-sakura-pk = {};
  desu.secrets.vless-sakura-sid = {};
  desu.secrets.vless-sakura-uuid = {};

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
          server = config.desu.readUnsafeSecret "arumi-ip";
          server_port = 443;
          domain_strategy = "";
          packet_encoding = "";
          tls = {
            enabled = true;
            alpn = [ "h2" ];
            server_name = "updates.cdn-apple.com";
            reality = {
              enabled = true;
              public_key._secret = config.desu.secrets.arumi-singbox-pub.path;
              short_id._secret = config.desu.secrets.arumi-singbox-sid.path;
            };
            utls = { enabled = true; fingerprint = "edge"; };
          };
          uuid._secret = config.desu.secrets.arumi-singbox-koi-uuid.path;
        }
        {
          # thanks kamillaova
          tag = "xtls-sakura";
          flow = "xtls-rprx-vision";
          server._secret = config.desu.secrets.vless-sakura-ip.path;
          server_port = 443;
          tls = {
            alpn = [ "h2" ];
            enabled = true;
            reality = {
              enabled = true;
              public_key._secret = config.desu.secrets.vless-sakura-pk.path;
              short_id._secret = config.desu.secrets.vless-sakura-sid.path;
            };
            server_name = "telegram.org";
            utls = { enabled = true; fingerprint = "edge"; };
          };
          type = "vless";
          uuid._secret = config.desu.secrets.vless-sakura-uuid.path;
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
