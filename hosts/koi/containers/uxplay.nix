{ abs, lib, pkgs, config, ... }@inputs:
let
  containers = import (abs "lib/containers.nix") inputs;
  uxplay = import (abs "services/uxplay.nix") inputs;
in
{
  imports = [
    (containers.mkNixosContainer {
      name = "uxplay";
      ip = "10.42.0.6";
      private = false;

      config = { ... }: {
        imports = [
          (uxplay {
            params = [
              "-p 7000"
              "-vs 0"
              "-async"
              "-n koi -nh"
            ];
            withAvahi = true;
          })
        ];

        networking.firewall.allowedTCPPorts = [ 7000 7001 7002 ];
        networking.firewall.allowedUDPPorts = [ 7000 7001 7002 ];
        services.avahi.openFirewall = true;
      };

      containerConfig.extraFlags = [
        "--bind=/run/pipewire"
        "--bind=/dev/snd"
        "--bind=/dev/shm"
      ];
    })
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    systemWide = true;
  };
}
