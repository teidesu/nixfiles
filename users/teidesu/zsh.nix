{ pkgs, lib, ... }:

let 
  starshipConfig = {
    # based on https://starship.rs/presets/pastel-powerline.html
    format = 
      "$character" +
      "$hostname" +
      "[](fg:#be15dc bg:#FCA17D)" +
      "$git_branch" +
      "$git_status" +
      "[](fg:#FCA17D bg:#86BBD8)" +
      "$nodejs" +
      "[](fg:#86BBD8 bg:#33658A)" +
      "$directory" +
      "[ ](fg:#33658A)" +
    "";
    add_newline = false;

    character = {
      success_symbol = "[](#be15dc)[ алина 🌸 ](bg:#be15dc)";
      error_symbol = "[](#dc156b)[ алина 🌸 ](bg:#be15dc)";
      format = "$symbol";
    };

    hostname = {
      style = ''bg:#be15dc'';
      format = "[$hostname ]($style)";
      ssh_only = true;
    };

    directory = {
      style = "bg:#33658A";
      format = "[ $path ]($style)";
      truncation_length = 3;
      truncation_symbol = "… /";
    };

    git_branch = {
      symbol = "";
      style = "bg:#FCA17D fg:black";
      format = "[ $symbol $branch ]($style)";
    };
    git_status = {
      style = "bg:#FCA17D fg:black";
      format = "[$all_status$ahead_behind ]($style)";
    };

    nodejs = {
      symbol = "";
      style = "bg:#86BBD8 fg:black";
      version_format = "$major.$minor";
      format = "[ $symbol ($version) ]($style)";
    };

    env_var._HOST_COLOR = {
      format = "$env_value";
    };
  };
in {
  programs.zsh = {
    enable = true;

    # oh-my-zsh = {
    #   enable = true;
    #   theme = "agnoster";
    #   extraConfig = ''
    #     zstyle ':bracketed-paste-magic' active-widgets '.self-*'
    #   '';
    # };

    syntaxHighlighting.enable = true;
    enableAutosuggestions = true;

    shellAliases = {
      "rm" = "rm -f";
      "entervenv" = "source venv/bin/activate";
      "ls" = "ls --color=auto";
      "ll" = "ls -l --color=auto";
    } // lib.optionalAttrs (pkgs.stdenv.isLinux) {
      "systemctl" = "sudo systemctl";
    };

    initExtra = ''
      unsetopt correct_all
      zstyle ':bracketed-paste-magic' active-widgets '.self-*'

      export _HOST_COLOR="#$(([##16]`hostname | cksum | cut -f 1 -d ' '` % 16777215))"
      export STARSHIP_CONFIG=${(pkgs.formats.toml {}).generate "starship.toml" starshipConfig}
      eval "$(${pkgs.starship}/bin/starship init zsh)"

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
