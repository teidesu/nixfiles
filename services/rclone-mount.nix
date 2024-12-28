{ config, lib, pkgs, ... }:

{
  options.services.rclone-mount = with lib; {
    enable = mkEnableOption "rclone";
    package = mkOption {
      type = types.package;
      default = pkgs.rclone;
      defaultText = "pkgs.rclone";
      description = "rclone package";
    };
    config = mkOption {
      type = types.attrs;
      description = "rclone config";
    };
    remote = mkOption {
      type = types.str;
      description = "rclone remote path to mount";
    };
    mountPoint = mkOption {
      type = types.str;
      description = "rclone mount point";
    };
    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "extra rclone arguments";
    };
    serviceName = mkOption {
      type = types.str;
      default = "rclone-mount";
      description = "rclone service name";
    };
  };

  config = let 
    cfg = config.services.rclone-mount;

    allArgs = cfg.extraArgs ++ [
      cfg.remote
      cfg.mountPoint
    ];

    rcloneConfig = (pkgs.formats.ini {}).generate "rclone.conf" cfg.config;
  in lib.mkIf cfg.enable {
    systemd.services.${cfg.serviceName} = {
      description = "rclone-mount Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.fuse ];
      serviceConfig = {
        User = "root";
        Group = "root";
        ExecStart = "${cfg.package}/bin/rclone --config ${rcloneConfig} mount ${builtins.concatStringsSep " " (map lib.escapeShellArg allArgs)}";
        ExecStop = "${pkgs.fuse}/bin/fusermount -uz ${lib.escapeShellArg cfg.mountPoint}";
        Restart = "on-failure";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.mountPoint} 0777 root root -"
    ];
  };
}