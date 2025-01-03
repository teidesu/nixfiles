{ ... }: 

{
  system.defaults.LaunchServices.LSQuarantine = false;
  system.defaults.NSGlobalDomain = {
    AppleEnableMouseSwipeNavigateWithScrolls = false;
    AppleEnableSwipeNavigateWithScrolls = false;
    ApplePressAndHoldEnabled = false;
    AppleShowAllFiles = true;
    AppleShowAllExtensions = true;
    AppleFontSmoothing = 0;
    AppleShowScrollBars = "WhenScrolling";
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    NSWindowShouldDragOnGesture = true;
    NSDocumentSaveNewDocumentsToCloud = false;
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;
    InitialKeyRepeat = 10;
    KeyRepeat = 1;
    AppleKeyboardUIMode = 3;
    NSWindowResizeTime = 0.1;
    "com.apple.keyboard.fnState" = true;
  };
  system.defaults.alf.allowdownloadsignedenabled = 1;
  system.defaults.dock = {
    mru-spaces = false;
    orientation = "left";
    show-recents = false;
    tilesize = 36;
    wvous-bl-corner = 1;
    wvous-br-corner = 1;
    wvous-tl-corner = 1;
    wvous-tr-corner = 1;
  };
  system.defaults.finder = {
    FXDefaultSearchScope = "SCcf";
    FXEnableExtensionChangeWarning = false;
    FXPreferredViewStyle = "Nlsv";
    ShowPathbar = true;
    ShowStatusBar = true;
  };
  system.defaults.CustomUserPreferences = {
    NSGlobalDomain = {
      TSMLanguageIndicatorEnabled = 0;
      QLPanelAnimationDuration = 0;
      NSAutomaticWindowAnimationsEnabled = 0;
    };

    "com.apple.screencapture".location = "~/Pictures";
    "com.apple.finder" = {
      _FXSortFoldersFirst = true;
      CreateDesktop = false;
      ShowHardDrivesOnDesktop = false;
      ShowExternalHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
      ShowMountedServersOnDesktop = false;
    };
    "com.apple.desktopservices" = {
      DSDontWriteUSBStores = true;
      DSDontWriteNetworkStores = true;
    };

    "com.apple.BluetoothAudioAgent" = {
      # from https://github.com/joeyhoer/starter/blob/master/system/bluetooth.sh
      "Apple Bitpool Max (editable)" = 80;
      "Apple Bitpool Min (editable)" = 48;
      "Apple Initial Bitpool (editable)" = 40;
      "Negotiated Bitpool" = 48;
      "Negotiated Bitpool Max" = 53;
      "Negotiated Bitpool Min" = 48;
      "Stream - Flush Ring on Packet Drop (editable)" = 30;
      "Stream - Max Outstanding Packets (editable)" = 15;
      "Stream Resume Delay" = "0.75";
    };

    "com.apple.dock".size-immutable = true;
    "com.apple.frameworks.diskimages".skip-verify = true;
    "com.apple.CrashReporter".UseUNC = 1;
    com.apple.helpviewer.DevMode = true;
  };
}