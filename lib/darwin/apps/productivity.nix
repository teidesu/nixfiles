{ callPackage, ... }: 

let 
  common = callPackage ./common.nix {};
in with common; {
  raycast = downloadAndInstallDmgApp {
    url = "https://releases.raycast.com/download";
    filename = "Raycast.app";
  };
  
  karabiner = downloadAndInstallDmgPkg {
    url = "https://github.com/pqrs-org/Karabiner-Elements/releases/download/v14.13.0/Karabiner-Elements-14.13.0.dmg";
    filename = "Karabiner-Elements.pkg";
    condition = "! -d /Applications/Karabiner-Elements.app";
  };

  alacritty = downloadAndInstallDmgApp {
    url = "https://github.com/alacritty/alacritty/releases/download/v0.13.2/Alacritty-v0.13.2.dmg";
    filename = "Alacritty.app";
  };
}