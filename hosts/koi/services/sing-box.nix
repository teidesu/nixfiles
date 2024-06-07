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
    ])
  ];

  services.sing-box = {
    enable = true;
    settings = {
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
            rule_set = "rkn";
            query_type = [ "A" "AAAA" ];
            server = "dns-fakeip";
          }
        ];
        servers = [
          # upstream dns
          {
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
        
        # "fake ip" setup.
        # setup for keenetic:
        # 1. create a proxy outbound (see https://help.keenetic.com/hc/ru/articles/7474374790300)
        # 2. create a static route for v4, can be done via web ui: Static Routes > Create, Route type = Route to network,
        #    Destination network address & Subnet mask – from `inet4_range`, interface = [our proxy]
        # 3. create a static route for v6, can be done via telnet: `ipv6 route [inet6_range] Proxy0` (interface name may differ)
        # 4. set up keenetic to use our dns server: 
        # 4.1. setup opkg
        # 4.2. install dnsmasq
        # 4.3. put something along this in /opt/etc/dnsmasq.conf:
        #     no-resolv
        #     bind-dynamic
        #     listen-address=127.0.0.1
        #     listen-address=10.42.0.1
        #     except-interface=lo
        #     cache-size=2500
        #     port=53
        #     
        #     server=10.42.0.2#5353 # <- ip of the server
        #     server=8.8.8.8
        #     strict-order
        # 4.4. run `opkg dns-override` via telnet
        # 4.5. set up the router as the only dns server in dhcp settings
        fakeip = {
          enabled = true;
          inet4_range = "10.224.0.0/11";
          inet6_range = "fd3e:dead:dead::/48";
        };
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
          tag = "auto";
          type = "urltest";
          outbounds = [
            "xtls-madoka"
            "xtls-homura"
          ];
        }
      ];

      route = {
        final = "auto";
        rules = [
          {
            inbound = [ "dns-in" ];
            outbound = "dns-out";
          }
          {
            outbound = "dns-out";
            port = [ 53 ];
          }
        ];

        rule_set = [
          {
            tag = "rkn";
            format = "binary";

            type = "remote";
            url = "https://github.com/teidesu/rkn-singbox/raw/ruleset/rkn-ruleset.srs";
          }
        ];
      };
      
      experimental = {
        cache_file = {
          enabled = true; 
          store_fakeip = true; 
        };

        # clash_api = {
        #   external_controller = "127.0.0.1:9090";
        #   external_ui = "dashboard";
        # };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 5353 7890 ];
  networking.firewall.allowedUDPPorts = [ 5353 ]; 
}
