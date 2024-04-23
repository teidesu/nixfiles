{ home ? {}, ... }:

{
  imports = [
    ./fonts.nix
  ];

  users.users.teidesu = {
    home = "/Users/teidesu";
  };

  home-manager.users.teidesu = { pkgs, ... }: {
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
    ];

    home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  };
}