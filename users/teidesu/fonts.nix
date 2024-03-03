{ pkgs, lib, ... }:

{
  fonts.fonts = [
    (pkgs.fetchzip {
      name = "iosevka-nerd";
      url = "https://s3.tei.su/iosevka-nerd.tgz";
      hash = "sha256-WrtCS1nwsGtYG7W7EiaaC4LVq1bGod4ygFC7VpSuDx0=";
    })
  ];
}