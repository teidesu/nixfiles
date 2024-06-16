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
      dns = {
        rules = [
          {
            outbound = [ "any" ];
            server = "dns-coredns";
          }
          {
            # suffixes specific to our coredns configuration
            # we don't want to expose them in the proxy
            domain_suffix = [
              ".docker"
              ".containers"
            ];
            server = "dns-block";
          }
          {
            rule_set = "adblock";
            server = "dns-block";
          }
          {
            query_type = [ "A" "AAAA" ];
            server = "dns-fakeip";
          }
        ];
        servers = [
          {
            # upstream dns
            address = "127.0.0.1";
            tag = "dns-coredns";
            detour = "direct";
          }
          { tag = "dns-fakeip"; address = "fakeip"; }
          {
            tag = "dns-block";
            address = "rcode://success";
          }
        ];
        
        fakeip = {
          enabled = true;
          inet4_range = "10.224.0.0/11";
          inet6_range = "fd3e:dead:dead::/48";
        };
        # important for fakeip to work, otherwise cache from upstream gets mixed up with fakeip cache
        independent_cache = true;
      };

      inbounds = [
        {
          tag = "dns-in";
          type = "direct";
          listen = "0.0.0.0";
          listen_port = 5353;
        }
        {
          tag = "mixed-in";
          type = "mixed";
          listen = "0.0.0.0";
          listen_port = 7890;
        }
        {
          tag = "personal-in";
          type = "mixed";
          listen = "127.0.0.1";
          listen_port = 7891;
        }
        {
          # sing-box doesn't properly support udp over socks, so we use
          # xkeen on router side with a minimal config to connect to this
          # sing-box instance via plain ss, and all further routing/proxying is done here.
          tag = "router-in";
          type = "shadowsocks";
          listen = "0.0.0.0";
          listen_port = 7899;
          method = "none";
          password = "";
        }
      ];

      outbounds = [
        { tag = "direct"; type = "direct"; }
        { tag = "dns-out"; type = "dns"; }
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
          tag = "personal-proxy";
          type = "urltest";
          outbounds = [
            "xtls-madoka"
            "xtls-homura"
          ];
        }
        {
          tag = "final";
          type = "selector";
          outbounds = [
            "xtls-madoka"
            "xtls-homura"
            "xtls-sakura"
            "direct"
          ];
          default = "xtls-sakura";
        }
      ];

      route = {
        final = "final";
        rules = [
          {
            inbound = [ "dns-in" ];
            outbound = "dns-out";
          }
          {
            inbound = [ "personal-in" ];
            outbound = "personal-proxy";
          }
          {
            # bypass proxy for...
            domain = [
              # most of these can be removed once we update to 1.9.0 (https://sing-box.sagernet.org/migration/#domain_suffix-behavior-update)
              "soundcloud.com"
              "youtube.com"
              "yandex-team.ru"
              "gosuslugi.ru"
              "mos.ru"
              "antizapret.prostovpn.org"
            ];
            domain_suffix = [
              ".soundcloud.com" # russian ips don't have ads
              ".youtube.com" # russian ips don't have ads
              ".yandex.net"
              ".yandex-team.ru"
              ".vk.com"
              ".gosuslugi.ru"
              ".mos.ru"
              ".stupid.fish"
            ];
            domain_keyword = [
              ".aki-game.net" # wuthering waves
              ".aki-game.com" # wuthering waves
            ];
            inbound = [ "router-in" ]; # if we are connected via some other inbound, we want to proxy everything.
            outbound = "direct";
          }
        ];

        rule_set = [
          {
            tag = "adblock";
            format = "binary";

            type = "remote";
            url = "https://adrules.top/adrules-singbox.srs";
          }
        ];
      };
      
      experimental = {
        cache_file = {
          enabled = true; 
          store_fakeip = true; 
        };

        clash_api = {
          # no secret because it's only available for nat so who cares
          external_controller = "0.0.0.0:7900";
          external_ui = "dashboard";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 5353 7890 7899 7900 ];
  networking.firewall.allowedUDPPorts = [ 5353 7899 ]; 
}
