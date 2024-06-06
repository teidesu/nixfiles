{ pkgs, abs, config, ... }@inputs:

{
  services.cage = {
    enable = true;
    user = "cage";
    program = "${pkgs.mpv}/bin/mpv /mnt/puffer/Downloads/anime --shuffle --loop-playlist --directory-mode=recursive";
    environment = {
      WLR_LIBINPUT_NO_DEVICES = "1";
    };
  };

  users.users.cage = {
    isNormalUser = true;
    description = "Guest account for Cage";
    createHome = false;
    shell = pkgs.shadow;
  };
}
