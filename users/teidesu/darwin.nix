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

    home.file.".config/rio" = {
      source = ./assets/rio;
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
  };
}