{ config, abs, lib, pkgs, modulesPath, ... }@inputs:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "uas" "usb_storage" "sd_mod" "tpm_crb" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/49a88223-231b-4fe4-8d2f-13799a3fad32";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-path/pci-0000:01:00.0-nvme-1-part1";
    fsType = "vfat";
  };

  fileSystems."/mnt/puffer" =
    {
      device = "/dev/mapper/puffer";
      fsType = "ext4";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/c418bb69-15cf-4d47-b9a0-0cf7191551da"; }];
  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-path/pci-0000:01:00.0-nvme-1-part2";
    preLVM = true;
    allowDiscards = true;
  };
  boot.initrd.luks.devices.puffer = {
    device = "/dev/disk/by-path/pci-0000:04:00.3-usb-0:4:1.0-scsi-0:0:0:0-part1";
    preLVM = true;
    allowDiscards = true;
  };
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.firmware = [ pkgs.alsa-firmware ];
}
