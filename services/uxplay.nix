{ lib, pkgs, ... }:

{
  # UXPlay parameters
  params ? [ ]
  # Whether to also set up avahi daemon
, withAvahi ? false
, # Name of the systemd service
  serviceName ? "uxplay"
, # UXPlay package
  package ? pkgs.uxplay
, serviceConfig ? { }
}:
let
  paramsJoined = builtins.concatStringsSep " " params;
in
{
  systemd.services.${serviceName} = {
    description = "${serviceName} Daemon";
    after = [ "network.target" ] ++ lib.optionals withAvahi [ "avahi-daemon.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.PrivateTmp = true;
    script = ''
      sleep 5 # idk needed for some reason
      exec ${package}/bin/uxplay ${paramsJoined}
    '';
  } // serviceConfig;
} // lib.optionalAttrs withAvahi {
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
}