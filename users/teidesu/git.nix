{ pkgs, ... }: 

let 
  isDarwin = pkgs.stdenv.isDarwin;
in {
  programs.git = {
    enable = true;
    userName = "alina sireneva";
    userEmail = "alina@tei.su";
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXaJrbD5SHp3HDtRX7YxrjO7wpcoY/L41Oc78IdT/l4";
      signByDefault = true;
    };

    extraConfig = {
      gpg.format = "ssh";
      "gpg \"ssh\"" = if isDarwin then {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      } else {
        defaultKeyCommand = "ssh-add -L";
      };
      push.autoSetupRemote = "true";
    };
  };
}