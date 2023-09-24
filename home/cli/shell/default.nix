{pkgs, ...}: {
  imports = [./starship_format.nix];

  programs = {
    starship = {
      enable = true;
      enableTransience = true;
      settings =
        {
          username = {
            show_always = true;
            format = "[$user]($style)";
          };
          hostname = {
            ssh_only = false;
            format = "@[$ssh_symbol$hostname]($style) ";
          };
          localip = {
            disabled = false;
            ssh_only = true;
            format = "[$localipv4]($style) ";
          };
          directory = {
            truncation_length = 20;
            truncation_symbol = ".../";
            style = "bold lavender";
            format = "in [$path]($style)[$read_only]($read_only_style)";
          };
          git_branch = {
            format = "[$symbol$branch(:$remote_branch)]($style) ";
          };
          git_commit = {
            tag_disabled = false;
            only_detached = false;
          };
          git_metrics = {
            disabled = false;
          };
          character = {
            success_symbol = "[❯](green)";
            error_symbol = "[❯](red)";
            vimcmd_symbol = "[❮](green)";
          };
          time = {
            disabled = false;
            use_12hr = true;
          };
          palette = "catppuccin_mocha";
        }
        // builtins.fromTOML (builtins.readFile (pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "starship";
            rev = "5629d2356f62a9f2f8efad3ff37476c19969bd4f";
            hash = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
          }
          + /palettes/mocha.toml));
    };

    fish = {
      enable = true;
      interactiveShellInit = ''${pkgs.starship}/bin/starship init fish | source'';
      functions = {
        starship_transient_rprompt_func = ''
          starship module time
        '';
      };
      plugins = [
        {
          name = "sponge";
          src = pkgs.fishPlugins.sponge.src;
        }
        {
          name = "colored-man-pages";
          src = pkgs.fishPlugins.colored-man-pages.src;
        }
        {
          name = "bass";
          src = pkgs.fishPlugins.bass.src;
        }
        {
          name = "z";
          src = pkgs.fishPlugins.z.src;
        }
      ];
    };

    bash = {
      enable = true;
      initExtra = ''eval "$(${pkgs.starship}/bin/starship init bash)"'';
    };

    k9s = {
      enable = true;
    };
  };
}
