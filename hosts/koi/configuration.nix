{ pkgs
, abs
, inputs
, ...
}:

{
  imports = [
    (abs "hosts/nixos-common.nix")
    (abs "users/teidesu/server.nix")
    ./hardware-configuration.nix

    ./partials/fde.nix
    ./partials/docker.nix
    ./partials/avahi.nix

    ./services/coredns.nix
    ./services/sing-box.nix
    ./services/nginx.nix
    ./services/phpfront.nix
    ./services/postgresql.nix
    ./services/landing
    ./services/terraria.nix

    ./containers/torrent.nix
    ./containers/vaultwarden.nix
    ./containers/sftpgo
    ./containers/verdaccio
    ./containers/sharkey
    ./containers/pds
    # ./containers/navidrome
    ./containers/conduwuit
    ./containers/zond
    ./containers/kanidm
    ./containers/siyuan
    ./containers/memos
    ./containers/wakapi
    ./containers/teisu.nix
    ./containers/bots/pcre-sub-bot.nix
    ./containers/bots/channel-logger-bot.nix
    ./vms/hass.nix
    ./vms/bnuuy.nix
    # ./vms/windows.nix
  ];

  networking = {
    hostName = "koi";
    # nftables.enable = true;

    useDHCP = false;
    interfaces = {
      br0 = {
        ipv4.addresses = [{
          address = "10.42.0.2";
          prefixLength = 16;
        }];
      };
    };

    bridges = {
      br0 = {
        interfaces = [ "enp2s0" ];
      };
    };

    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" "vb-+" "veth+" ];
      externalInterface = "br0";
    };

    defaultGateway = {
      address = "10.42.0.1";
      interface = "br0";
    };
    nameservers = [
      "127.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    allowedBridges = [ "br0" ];
  };

  boot.extraModprobeConfig = ''
    options kvm_amd avic=1 nested=0
    options kvm ignore_msrs=N report_ignored_msrs=Y
  '';

  hardware.bluetooth.enable = true;
  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "8192";
  }];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.kernelParams = [ "efi_pstore.pstore_disable=0" ];

  services.desu-deploy = {
    enable = true;
    key = builtins.readFile (abs "ssh/desu-deploy.pub");
  };
}

