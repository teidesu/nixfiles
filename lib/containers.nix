{ pkgs, lib, ... }@inputs:
let
  trivial = import ./trivial.nix inputs;
in
{
  # this function is quite deeply tied to my home network setup
  # i should make it more generic one day
  mkNixosContainer =
    { name
    , config
    , ip
    , private ? true
    , mounts ? { }
    , containerConfig ? { }
    , ephemeral ? true
    }: {
      containers.${name} = {
        autoStart = true;
        ephemeral = ephemeral;
        privateNetwork = true;

        config = { lib, ... }: {
          imports = [
            config
          ];

          networking = {
            defaultGateway = "10.42.0.1";

            # https://github.com/NixOS/nixpkgs/issues/162686
            useHostResolvConf = lib.mkForce false;

            nameservers = [
              "10.42.0.2"
              "8.8.8.8"
              "8.8.4.4"
            ];
          };
          system.stateVersion = "24.05";
        };

        bindMounts = mounts;
      } // (if private then {
        hostAddress = "10.88${ip}";
        localAddress = "10.89${ip}";
      } else {
        hostBridge = "br0";
        localAddress = "${ip}/16";
      }) // containerConfig;
    };

  # nixos oci-containers fucking suck, so we just do a one-shot 
  # systemd service that invokes docker-compose
  #
  # not very reproducible nor declarative, but compatible with pretty much
  # anything, which is (imo) more important for a home server
  mkDockerComposeContainer =
    { directory
    , name ? builtins.baseNameOf directory
    , autoStart ? true
    , extraConfig ? { }
    , env ? { }
    , envFiles ? [ ]
    , extraFlags ? [ ]
    , after ? [ ]
    }:
    let
      # referencing the file directly would make the service dependant
      # on the entire flake, resulting in the container being restarted
      # every time we change anything at all
      storeDir = trivial.storeDirectory directory;

      inlineEnvNames = builtins.attrNames env;
      inlineEnvDrv = lib.optionals (builtins.length inlineEnvNames != 0) [
        (pkgs.writeText "${name}.env" (
          builtins.concatStringsSep "\n" (
            map (name: "${name}=${builtins.toJSON env.${name}}") inlineEnvNames
          )
        ))
      ];
      allEnvFiles = envFiles ++ inlineEnvDrv;

      cmdline = builtins.concatStringsSep " " (
        [
          "--build"
          "--remove-orphans"
        ] ++ extraFlags
      );
      cmdlineBeforeUp = builtins.concatStringsSep " " (
        map (env: "--env-file ${lib.escapeShellArg env}") allEnvFiles
      );
    in
    {
      systemd.services."docker-compose-${name}" = {
        wantedBy = if autoStart then [ "multi-user.target" ] else [ ];
        after = [ "docker.service" "docker.socket" ] ++ after;
        serviceConfig = {
          WorkingDirectory = storeDir;
          ExecStart = "${pkgs.docker}/bin/docker compose ${cmdlineBeforeUp} up ${cmdline}";
          ExecStopPost = "${pkgs.docker}/bin/docker compose down";
        } // (extraConfig.serviceConfig or { });
      } // (builtins.removeAttrs extraConfig [ "serviceConfig" ]);
    };
  
  # buildDockerfile = { name, context }: builtins.derivation {
  #   name = "${name}-image";
  #   # __noChroot = true;
  #   src = context;
  #   builder = pkgs.writeShellScript "builder.sh" (let 
  #     docker = "${pkgs.docker}/bin/docker";
  #   in ''
  #     ${docker} build -t ${name} $src
  #     ${docker} save -o $out ${name}
  #     ${docker} image rm ${name}
  #   '');
  #   system = pkgs.system;
  # };
}
