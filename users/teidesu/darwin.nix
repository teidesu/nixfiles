{ 
  home ? {},
  pkgs,
  ...
}:

{
  imports = [
    ./fonts.nix
    ./macos-defaults.nix
  ];

  users.users.teidesu = {
    home = "/Users/teidesu";
    shell = pkgs.zsh;
  };

  age.identityPaths = [
    "/Users/teidesu/.ssh/agenix-key"
  ];

  home-manager.users.teidesu = { pkgs, abs, ... }: {
    imports = [
      ./common.nix
      
      home
    ];

    home.packages = with pkgs; [
      scc
      ripgrep
      fnm
      aria2
      ffmpeg-full
      hyfetch
      wget
      watch
      curl
      android-tools
      imagemagick
      rustup
      yt-dlp
      cloudflared
      sshfs
      sshpass
      (python311.withPackages (ps: with ps; [
        pipx
      ]))
    ];

    home.file.".config/ghostty" = {
      source = ./assets/ghostty;
      recursive = true;
    };
    home.file.".config/karabiner" = {
      source = ./assets/karabiner;
      recursive = true;
    };
    home.file.".config/atuin" = {
      source = ./assets/atuin;
      recursive = true;
    };
    home.file.".config/linearmouse" = {
      source = ./assets/linearmouse;
      recursive = true;
    };
    home.file.".config/aerospace" = {
      source = ./assets/aerospace;
      recursive = true;
    };
    home.file."Library/Application Support/Firefox" = {
      source = ./assets/firefox;
      recursive = true;
    };
  };
}