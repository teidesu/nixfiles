{ ... }:

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
}
