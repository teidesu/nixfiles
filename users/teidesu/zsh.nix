{ pkgs, lib, ... }:

let 
  starshipConfig = {
    # based on https://starship.rs/presets/pastel-powerline.html
    format = 
      "[ алина 🌸](bg:#be15dc fg:#ffffff)[](#be15dc) " +
      ''''${env_var._NIX_SHELL_INFO}'' +
      "$nix_shell" +
      "$hostname" +
      "$git_branch" +
      "$git_status" +
      "$nodejs" +
      "\n" +
      "$directory" +
      "$character" +
    "";
    add_newline = true;

    character = {
      success_symbol = "[❱](#26dc15)";
      error_symbol = "[❱](#dc156b)";
    };

    hostname = {
      style = "bg:#a2d3f6 fg:black";
      format = "[](#a2d3f6)[󰒋 $hostname]($style)[](#a2d3f6) ";
      ssh_only = true;
    };

    directory = {
      style = "blue";
      format = "[$path ]($style)";
      truncation_length = 3;
      truncation_symbol = "… /";
    };

    git_branch = {
      symbol = "";
      style = "bg:#FCA17D fg:black";
      format = "[](fg:#FCA17D)[$symbol $branch ]($style)";
    };
    git_status = {
      style = "bg:#FCA17D fg:black";
      format = "[$all_status$ahead_behind]($style)[](fg:#FCA17D) ";
    };

    nix_shell = {
      style = "bg:#8ab3db fg:black";
      format = "[](#8ab3db)[  $name]($style)[](#8ab3db) ";
    };

    env_var._NIX_SHELL_INFO = {
      style = "bg:#8ab3db fg:black";
      format = "[](#8ab3db)[  $env_value]($style)[](#8ab3db) ";
    };

    nodejs = {
      style = "bg:#a1d886 fg:black";
      version_format = "$major.$minor";
      format = "[](#a1d886)[ $version]($style)[](#a1d886) ";
    };
  };
in {
  programs.zsh = {
    enable = true;

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

      export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
      zstyle ':completion:*' format $'\e[2;37mcompleting %d\e[m'
      source <(carapace _carapace zsh)

      CASE_SENSITIVE="false"
      HYPHEN_INSENSITIVE="true"
      ENABLE_CORRECTION="true"
      COMPLETION_WAITING_DOTS="true"
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=5"

      # search in history with up and down arrow 
      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey "^[[A" up-line-or-beginning-search
      bindkey "^[OA" up-line-or-beginning-search
      bindkey "^[[B" down-line-or-beginning-search
      bindkey "^[OB" down-line-or-beginning-search

      WORDCHARS="*?_-.[]~=&;!#$%^"

      # tab completion menu
      autoload -Uz compinit
      compinit
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list ''' 'm:{a-zA-Z}={A-Za-z}'

      if command -v micro &> /dev/null; then
        export EDITOR="micro"
      elif command -v nano &> /dev/null; then
        export EDITOR="nano"
      fi

      if command -v fnm &> /dev/null; then
        eval "$(fnm env)"
      fi

      function ns {
        newargs=()
        for arg in $@; do
          # if doesn't start with - and doesn't contain # - assume its a nixpkgs package
          if [[ $arg != -* && $arg != *#* ]]; then
            newargs+=("nixpkgs#$arg")
          else
            newargs+=($arg)
          fi
        done

        _NIX_SHELL_INFO="''${newargs[@]}" nix shell "''${newargs[@]}"
      }

      export PATH="$HOME/.cargo/bin/:$HOME/.bun/bin:$HOME/.deno/bin:$PATH"
    '';
  };

  programs.nix-index.enable = true;
}
