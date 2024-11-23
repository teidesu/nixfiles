{ abs, pkgs, config, ... }@inputs:
let
  containers = (import (abs "lib/containers.nix") inputs);
in
{
  desu.secrets.qbt-dl-webhook.mode = "777";
  desu.secrets.torrent-proxy-env.mode = "777";
  
  imports = [
    (containers.mkNixosContainer {
      name = "torrent";
      ephemeral = false;
      ip = "10.42.0.9";
      private = false;

      config = { ... }: {
        imports = [
          (import (abs "services/qbittorrent.nix") inputs {
            port = 80;
            serviceConfig = {
              AmbientCapabilities = "CAP_NET_BIND_SERVICE";
            };
            setup = { config, ... }: ''
              mkdir -p /var/lib/qbittorrent/temp
              dl_webhook=`cat /mnt/secrets/qbt-dl-webhook`
              sed -i "s|%DL_WEBHOOK%|$dl_webhook|g" ${config}
            '';
            config = {
              Preferences = {
                # auth is managed by oidc proxy
                "WebUI\\AuthSubnetWhitelist" = "0.0.0.0/0"; 
                "WebUI\\AuthSubnetWhitelistEnabled" = "true";
                "WebUI\\ReverseProxySupportEnabled" = "true";
                "WebUI\\TrustedReverseProxiesList" = "10.42.0.2";
                "WebUI\\HostHeaderValidation" = "false";
                "WebUI\\CSRFProtection" = "false";
              };
              BitTorrent = {
                "Session\\DefaultSavePath" = "/mnt/download";
                "Session\\DisableAutoTMMByDefault" = "false";
                # puffer is an hdd, which bottlenecks the download speed
                # upload speed doesn't matter that much
                "Session\\TempPath" = "/var/lib/qbittorrent/temp";
                "Session\\TempPathEnabled" = "true";
                "Session\\Port" = "13370";
              };
              Network = {
                "PortForwardingEnabled" = "false";
                "Proxy\\IP" = "10.42.0.2";
                "Proxy\\Port" = "@Variant(\\0\\0\\0\\x85\\x1e\\xd2)"; # 7890
                "Proxy\\Type" = "SOCKS5";
                "Proxy\\HostnameLookupEnabled" = "true";
              };
              AutoRun = {
                enabled = "true";
                program = "/run/current-system/sw/bin/curl \\\"%DL_WEBHOOK%\\\" -X POST -d \\\"%N\\\"";
              };
            };
          })
        ];
        networking.firewall.allowedTCPPorts = [ 80 13370 ];
        networking.firewall.allowedUDPPorts = [ 13370 ];
      };

      mounts = {
        "/mnt/download" = {
          hostPath = "/mnt/puffer/Downloads";
          isReadOnly = false;
        };
        "/mnt/secrets/qbt-dl-webhook" = {
          hostPath = config.desu.secrets.qbt-dl-webhook.path;
          isReadOnly = true;
        };
      };
    })
  ];

  desu.openid-proxy.services.torrent = {
    clientId = "torrent";
    domain = "torrent.stupid.fish";
    upstream = "http://torrent.containers";
    envSecret = "torrent-proxy-env";
  };

  services.nginx.virtualHosts."torrent.stupid.fish" = {
    forceSSL = true;
    useACMEHost = "stupid.fish";

    locations."/" = {
      proxyPass = "http://torrent-oidc.docker$request_uri";
    };
  };
}
