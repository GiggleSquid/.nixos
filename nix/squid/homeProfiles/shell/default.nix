{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib // builtins;
in
{
  home = {
    packages = with nixpkgs; [
      ripgrep
      git
    ];
    shellAliases = {
      l = "lsd -Al";
      cat = "bat";
      mkdir = "mkdir -p";
      lg = "lazygit";
    };
  };

  xdg.configFile."btop/themes/catppuccin_mocha.theme" = {
    source = "${
      nixpkgs.catppuccin.override {
        themeList = [ "btop" ];
        variant = "mocha";
        accent = "peach";
      }
    }/btop/catppuccin_mocha.theme";
  };

  programs = {
    fish = {
      enable = true;
      plugins = [
        {
          name = "sponge";
          src = nixpkgs.fishPlugins.sponge.src;
        }
        {
          name = "fzf-fish";
          src = nixpkgs.fishPlugins.fzf-fish.src;
        }
        {
          name = "colored-man-pages";
          src = nixpkgs.fishPlugins.colored-man-pages.src;
        }
      ];
      interactiveShellInit = ''
        set sponge_delay 10
      '';
      functions = {
        starship_transient_rprompt_func = ''
          starship module time
        '';
      };
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [ "--cmd cd" ];
    };

    fd = {
      enable = true;
    };

    bat = {
      enable = true;
      config = {
        theme = "catppuccin-mocha";
      };
      themes = {
        catppuccin-mocha = {
          src = nixpkgs.catppuccin.override {
            themeList = [ "bat" ];
            variant = "mocha";
            accent = "peach";
          };
          file = "/bat/Catppuccin Mocha.tmTheme";
        };
      };
    };

    btop = {
      enable = true;
      settings = {
        color_theme = "catppuccin_mocha.theme";
      };
    };

    lsd = {
      enable = true;
      enableAliases = true;
      settings = {
        total-size = true;
      };
    };

    bash = {
      enable = true;
    };

    tmux = {
      enable = true;
    };

    starship = {
      enable = true;
      enableTransience = true;
      settings =
        {
          command_timeout = 1000;
          username = {
            show_always = true;
            style_user = "bold peach";
            style_root = "bold red";
            format = "[$user]($style)";
          };
          hostname = {
            ssh_only = false;
            style = "bold dimmed peach";
            format = "@[$hostname]($style) ";
          };
          localip = {
            disabled = false;
            ssh_only = true;
            style = "bold dimmed peach";
            format = "[\\[$localipv4\\]]($style) ";
          };
          directory = {
            truncation_length = 5;
            truncation_symbol = ".../";
            truncate_to_repo = false;
            style = "lavender";
            format = "[  ]($style)[$path]($style) [$read_only]($read_only_style) ";
            before_repo_root_style = "dimmed lavender";
            repo_root_style = "bold lavender";
            repo_root_format = "[  ]($style)[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style) [$read_only]($read_only_style) ";
          };
          git_branch = {
            style = "bold peach";
          };
          git_commit = {
            tag_disabled = false;
            only_detached = false;
            style = "bold dimmed lavender";
          };
          git_metrics = {
            disabled = false;
          };
          helm = {
            style = "bold text";
          };
          container = {
            style = "bold dimmed maroon";
          };
          shell = {
            disabled = false;
            style = "bold subtext1";
          };
          character = {
            success_symbol = "[❯](peach)";
            error_symbol = "[❯](red)";
            vimcmd_symbol = "[❮](peach)";
          };
          time = {
            disabled = false;
            use_12hr = true;
          };
          format = ''
            [┌──](bold peach) $username$hostname$localip$sudo$shlvl
            [│](bold peach) ${
              lib.concatStrings [
                "$singularity"
                "$kubernetes"
                "$directory"
                "$vcsh"
                "$fossil_branch"
                "$git_branch"
                "$git_commit"
                "$git_state"
                "$git_metrics"
                "$git_status"
                "$hg_branch"
                "$pijul_channel"
                "$docker_context"
                "$package"
                "$c"
                "$cmake"
                "$cobol"
                "$daml"
                "$dart"
                "$deno"
                "$dotnet"
                "$elixir"
                "$elm"
                "$erlang"
                "$fennel"
                "$golang"
                "$guix_shell"
                "$haskell"
                "$haxe"
                "$helm"
                "$java"
                "$julia"
                "$kotlin"
                "$gradle"
                "$lua"
                "$nim"
                "$nodejs"
                "$ocaml"
                "$opa"
                "$perl"
                "$php"
                "$pulumi"
                "$purescript"
                "$python"
                "$raku"
                "$rlang"
                "$red"
                "$ruby"
                "$rust"
                "$scala"
                "$solidity"
                "$swift"
                "$terraform"
                "$vlang"
                "$vagrant"
                "$zig"
                "$buf"
                "$nix_shell"
                "$conda"
                "$meson"
                "$spack"
                "$memory_usage"
                "$aws"
                "$gcloud"
                "$openstack"
                "$azure"
                "$env_var"
                "$crystal"
                "$custom"
              ]
            }
            [└──](bold peach) $cmd_duration$jobs$battery$os$container$shell$character
          '';
          palette = "catppuccin_mocha";
        }
        // lib.fromTOML (
          lib.readFile "${
            nixpkgs.catppuccin.override {
              themeList = [ "starship" ];
              variant = "mocha";
              accent = "peach";
            }
          }/starship/mocha.toml"
        );
    };
  };
}
