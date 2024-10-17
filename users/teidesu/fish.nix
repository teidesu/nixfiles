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
      format = "[$all_status$ahead_behind ]($style)[](fg:#FCA17D) ";
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
  programs.fish = {
    enable = true;

    shellAliases = {
      "rm" = "rm -f";
      "entervenv" = "source venv/bin/activate";
      "ls" = "eza";
      "ll" = "eza -l";
      "cat" = "bat";
    } // lib.optionalAttrs (pkgs.stdenv.isLinux) {
      "systemctl" = "sudo systemctl";
    };

    shellInit = ''
      set fish_greeting

      export STARSHIP_CONFIG=${(pkgs.formats.toml {}).generate "starship.toml" starshipConfig}
      eval "$(${pkgs.starship}/bin/starship init fish)"

      export BAT_THEME="ansi"

      if command -q carapace
        set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional
        if test ! -f ~/.config/fish/completions/carapace.fish
          mkdir -p ~/.config/fish/completions
          carapace --list | awk '{print $1}' | xargs -I{} touch ~/.config/fish/completions/{}.fish # disable auto-loaded completions (#185)
        end
        
        carapace _carapace | source
      end

      if command -q atuin
        atuin init fish --disable-up-arrow | source
      end

      if command -q micro
        export EDITOR="micro"
      else if command -q nano
        export EDITOR="nano"
      end

      if command -q fnm
        eval "$(fnm env)"
      end

      function ns
        set -l newargs

        for arg in $argv
          # if doesn't start with - and doesn't contain # - assume its a nixpkgs package
          if test $arg != "-*"; and test $arg != "*#*"
            set -a newargs "nixpkgs#$arg"
          else
            set -a newargs $arg
          end
        end

        _NIX_SHELL_INFO="''$newargs" nix shell $newargs
      end

      fish_add_path ~/.local/bin
      fish_add_path ~/.cargo/bin
      fish_add_path ~/.bun/bin
      fish_add_path ~/.deno/bin
      fish_add_path ./node_modules/.bin
    '';
  };

  programs.nix-index.enable = true;
}
