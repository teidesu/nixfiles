{ pkgs, config, lib, ... }:

let 
  cfg = config.desu.postgresql;
in {
  options.desu.postgresql = with lib; {
    ensurePasswords = mkOption {
      type = types.attrsOf (types.str);
      default = {};
    };
  };

  config = {
    services.postgresql = {
      enable = true;
      enableJIT = true;
      enableTCPIP = true;
      package = pkgs.postgresql_15;
      dataDir = "/srv/postgres";

      authentication = ''
        host  all all 172.17.0.1/16 md5
      '';
    };

    # expose postgres to docker containers
    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 5432 -j nixos-fw-accept -i docker0
    '';

    systemd.services.postgresql.postStart = 
      builtins.concatStringsSep "\n" (
        lib.attrsets.mapAttrsToList (
          # who cares about injections LOL. also i hate bash
          user: password: ''$PSQL -tAc 'ALTER user "${user}" with password '"'"'${password}'"'"';' ''
        ) cfg.ensurePasswords
      );
  };
}