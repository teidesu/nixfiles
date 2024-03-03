{ pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      extraConfig = ''
        zstyle ':bracketed-paste-magic' active-widgets '.self-*'
      '';
    };

    syntaxHighlighting.enable = true;
    enableAutosuggestions = true;

    shellAliases = {
      "rm" = "rm -f";
      "entervenv" = "source venv/bin/activate";
    } // lib.optionalAttrs (pkgs.stdenv.isLinux) {
      "systemctl" = "sudo systemctl";
    };

    initExtra = ''
      unsetopt correct_all

      CURRENT_BG="$(( `hostname | cksum | cut -f 1 -d ' '` % 255 ))"
      CASE_SENSITIVE="false"
      HYPHEN_INSENSITIVE="true"
      ENABLE_CORRECTION="true"
      COMPLETION_WAITING_DOTS="true"
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=5"

      if command -v micro &> /dev/null; then
        export EDITOR="micro"
      elif command -v nano &> /dev/null; then
        export EDITOR="nano"
      fi

      if command -v fnm &> /dev/null; then
        eval "$(fnm env)"
      fi
    '';
  };
}
