{ config, lib, pkgs, ... }:

{
  options.services.geesefs = with lib; {
    enable = mkEnableOption "geesefs";
    package = mkOption {
      type = types.package;
      default = pkgs.geesefs;
      defaultText = "pkgs.geesefs";
      description = "geesefs package";
    };
    serviceName = mkOption {
      type = types.str;
      default = "geesefs";
      description = "geesefs service name";
    };
    args = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "geesefs arguments";
    };
    bucket = mkOption {
      type = types.str;
      description = "geesefs bucket name";
    };
    mountPoint = mkOption {
      type = types.str;
      description = "geesefs mount point";
    };
  };

  config = let 
    cfg = config.services.geesefs;

    allArgs = cfg.args ++ [
      cfg.bucket
      cfg.mountPoint
    ];
  in {
    systemd.services.${cfg.serviceName} = {
      description = "${cfg.serviceName} Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.fuse ];
      serviceConfig = {
        User = "root";
        Group = "root";
        Type = "forking";
        GuessMainPID = true;
        ExecStart = "${cfg.package}/bin/geesefs ${builtins.concatStringsSep " " (map lib.escapeShellArg allArgs)}";
        ExecStop = "fusermount -u ${lib.escapeShellArg cfg.mountPoint}";
        Restart = "on-failure";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.mountPoint} 0777 root root -"
    ];
  };
}