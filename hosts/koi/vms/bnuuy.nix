{ abs, pkgs, ... }@inputs:

let
  qemu = import (abs "lib/qemu.nix") inputs;

  macAddress = "b6:dc:95:aa:21:8e";
  initDisk = qemu.mkCloudInitDisk {
    user = {
      ssh_pwauth = false;
      hostname = "bnuuy";
      users = [
        {
          name = "teidesu";
          groups = "users,wheel";
          shell = "/bin/bash";
          sudo = "ALL=(ALL) NOPASSWD:ALL";
          ssh_authorized_keys = [
            (builtins.readFile (abs "ssh/teidesu.pub"))
          ];
        }
      ];
    };
    network = {
      version = 2;
      ethernets = {
        id0 = {
          match = { macaddress = macAddress; };
          wakeonlan = true;
          dhcp4 = true;
          addresses = [ "10.42.0.8/8" ];
          gateway4 = "10.42.0.2";
          nameservers = {
            search = [ "10.42.0.2" ];
          };
        };
      };
    };
  };
in
{
  # ubuntu vm for random ad-hoc garbage that i don't want to litter my host with
  systemd.services.bnuuy = qemu.mkSystemdService {
    name = "bnuuy";
    qemuOptions = {
      cores = "2";
      disks = [
        {
          name = "ubuntu";
          path = "/etc/vms/bnuuy.img";
        }
        initDisk
      ];
      inherit macAddress;
    };
  };

  networking.firewall.allowedTCPPorts = [ 5901 ];
}
