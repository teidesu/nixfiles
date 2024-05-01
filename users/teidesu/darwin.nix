{ 
  home ? {},
  ...
}:

{
  imports = [
    ./fonts.nix
    ./macos-defaults.nix
  ];

  users.users.teidesu = {
    home = "/Users/teidesu";
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
    ];

    home.file.".config/alacritty/alacritty.toml".source = ./assets/alacritty.toml;
    home.file.".config/new-alacritty-window.scpt".source = ./assets/new-alacritty-window.scpt; # todo: reference this directly from store
    home.file.".config/karabiner/karabiner.json".source = ./assets/karabiner.json;
  };
}