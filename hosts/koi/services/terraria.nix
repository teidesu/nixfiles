{ config, lib, pkgs, ... }:
let
  cfg = {
    enable = true;
    maxPlayers = 10;
    port = 7777;
    messageOfTheDay = "penis gaming";
    noUPnP = true;
    openFirewall = true;
    worldPath = "/srv/terraria/world.wld";
    dataDir = "/var/lib/terraria";
    password = null;
    banListPath = null;
    secure = false;
    autoCreatedWorldSize = "medium";
  };

  worldSizeMap = { small = 1; medium = 2; large = 3; };
  valFlag = name: val: lib.optionalString (val != null) "-${name} \"${lib.escape ["\\" "\""] (toString val)}\"";
  boolFlag = name: val: lib.optionalString val "-${name}";
  flags = [
    (valFlag "port" cfg.port)
    (valFlag "maxPlayers" cfg.maxPlayers)
    (valFlag "password" cfg.password)
    (valFlag "motd" cfg.messageOfTheDay)
    (valFlag "world" cfg.worldPath)
    (valFlag "autocreate" (builtins.getAttr cfg.autoCreatedWorldSize worldSizeMap))
    (valFlag "banlist" cfg.banListPath)
    (boolFlag "secure" cfg.secure)
    (boolFlag "noupnp" cfg.noUPnP)
  ];

  tmuxCmd = "${lib.getExe pkgs.tmux} -S ${lib.escapeShellArg cfg.dataDir}/terraria.sock";

  stopScript = pkgs.writeShellScript "terraria-stop" ''
    if ! [ -d "/proc/$1" ]; then
      exit 0
    fi
    
    log=$(${tmuxCmd} capture-pane -p)
    echo "$log" > /tmp/terraria-stop.log
    lastline=$(echo "$log" | grep . | tail -n1)

    # If the service is not configured to auto-start a world, it will show the world selection prompt
    # If the last non-empty line on-screen starts with "Choose World", we know the prompt is open
    if [[ "$lastline" =~ ^'Choose World' ]]; then
      # In this case, nothing needs to be saved, so we can kill the process
      ${tmuxCmd} kill-session
    else
      # Otherwise, we send the `exit` command
      ${tmuxCmd} send-keys Enter exit Enter
    fi

    # Wait for the process to stop
    tail --pid="$1" -f /dev/null
  '';
in
{
  users.users.terraria = {
    description = "Terraria server service user";
    group       = "terraria";
    home        = cfg.dataDir;
    createHome  = true;
    uid         = config.ids.uids.terraria;
  };

  users.groups.terraria = {
    gid = config.ids.gids.terraria;
  };

  systemd.services.terraria = {
    description   = "Terraria Server Service";
    wantedBy      = [ "multi-user.target" ];
    after         = [ "network.target" ];

    serviceConfig = {
      User    = "root";
      Group = "root";
      # Type = "forking";
      GuessMainPID = true;
      # UMask = 007;
      ExecStart = "${pkgs.terraria-server}/bin/TerrariaServer ${lib.concatStringsSep " " flags}";
      ExecStop = "kill -SIGINT $MAINPID";
    };
  };

  networking.firewall = lib.mkIf cfg.openFirewall {
    allowedTCPPorts = [ cfg.port ];
    allowedUDPPorts = [ cfg.port ];
  };
}