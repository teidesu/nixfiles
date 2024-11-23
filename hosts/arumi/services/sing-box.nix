{ config, pkgs, ... }:

{
  desu.secrets.arumi-singbox-pk = {};
  desu.secrets.arumi-singbox-sid = {};
  desu.secrets.arumi-singbox-users = {};

  services.sing-box = {
    enable = true;
    settings = {
      log = { level = "info"; timestamp = true; };
      inbounds = [
        {
          type = "vless";
          tag = "vless-in";
          listen = "::";
          listen_port = 443;
          sniff = true;
          sniff_override_destination = true;
          domain_strategy = "ipv4_only";
          users = []; # populated later in the preStart script
          tls = let server = "updates.cdn-apple.com"; in {
            enabled = true;
            server_name = server;
            reality = {
              enabled = true;
              handshake = { inherit server; server_port = 443; };
              private_key._secret = config.desu.secrets.arumi-singbox-pk.path;
              short_id = [ 
                { _secret = config.desu.secrets.arumi-singbox-sid.path; }
              ];
            };
          };
        }
      ];
      outbounds = [
        { type = "direct"; tag = "direct"; }
        { type = "block"; tag = "block"; }
      ];
    };
  };

  systemd.services.sing-box.preStart = let 
    file = "/etc/sing-box/config.json";
  in ''
    users=$(${pkgs.yaml2json}/bin/yaml2json < ${config.desu.secrets.arumi-singbox-users.path})
    ${pkgs.jq}/bin/jq --arg users "$users" \
      '.inbounds[0].users = ($users | fromjson | map({ "uuid": ., "flow": "xtls-rprx-vision" }))' \
      ${file} > ${file}.tmp
    mv ${file}.tmp ${file}
  '';

  networking.firewall.allowedTCPPorts = [ 443 ];
}