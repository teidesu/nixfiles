{ callPackage }: 

let 
  common = callPackage ./common.nix {};
in with common; {
  raycast = downloadAndInstallDmgApp {
    url = "https://releases.raycast.com/download";
    filename = "Raycast.app";
  };
  
  brave = downloadAndInstallDmgApp {
    url = "https://referrals.brave.com/latest/BRV010/Brave-Browser.dmg";
    filename = "Brave Browser.app";
  };
  
  snipaste = downloadAndInstallDmgApp {
    url = "https://dl.snipaste.com/mac-beta";
    filename = "Snipaste.app";
  };
  
  karabiner = downloadAndInstallDmgPkg {
    url = "https://github.com/pqrs-org/Karabiner-Elements/releases/download/v14.13.0/Karabiner-Elements-14.13.0.dmg";
    filename = "Karabiner-Elements.pkg";
    condition = "! -d /Applications/Karabiner-Elements.app";
  };

  forkgram = downloadAndInstallZipApp {
    url = "https://github.com/forkgram/tdesktop/releases/download/v4.16.10/Forkgram.macOS.no.auto-update_arm64.zip";
    filename = "Telegram.app";
    renameTo = "Forkgram.app";
  };
}