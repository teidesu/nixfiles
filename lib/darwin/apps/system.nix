{ callPackage }: 

let 
  common = callPackage ./common.nix {};
in with common; {
  wireguard = downloadAndInstallZipApp {
    url = "https://s3.tei.su/wireguard-mac-1.0.16.zip";
    filename = "WireGuard.app";
  };
  
  nekoray = downloadAndInstallZipApp {
    url = "https://github.com/abbasnaqdi/nekoray-macos/releases/download/3.26/nekoray_arm64.zip";
    filename = "nekoray_arm64.app";
    renameTo = "nekoray.app";
    # https://github.com/abbasnaqdi/nekoray-macos/issues/64
    afterInstall = ''
      plutil -insert LSUIElement -bool YES /Applications/nekoray.app/Contents/Info.plist
    '';
  };

  alacritty = downloadAndInstallDmgApp {
    url = "https://github.com/alacritty/alacritty/releases/download/v0.13.2/Alacritty-v0.13.2.dmg";
    filename = "Alacritty.app";
  };
}