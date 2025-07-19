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
      l = "eza -l --all --icons --time-style=long-iso --group-directories-first --total-size --group --git";
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
      functions = {
        starship_transient_rprompt_func = ''
          starship module time
        '';
      };
    };

    atuin = {
      enable = true;
      daemon.enable = true;
      enableFishIntegration = true;
      settings = {
        auto_sync = true;
        dialect = "uk";
        sync_address = "http://atuin.lan.gigglesquid.tech:8080";
        sync_frequency = "10m";
        inline_height = 0;
        search_mode = "fuzzy";
        filter_mode_shell_up_key_binding = "host";
        enter_accept = true;
        store_failed = false;
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

    gitui = {
      enable = true;
      # https://github.com/gitui-org/gitui/issues/2286
      # https://github.com/catppuccin/gitui/issues/17
      # theme =
      #   nixpkgs.fetchFromGitHub {
      #     owner = "catppuccin";
      #     repo = "gitui";
      #     rev = "df2f59f847e047ff119a105afff49238311b2d36";
      #     hash = "sha256-DRK/j3899qJW4qP1HKzgEtefz/tTJtwPkKtoIzuoTj0=";
      #   }
      #   + "/themes/catppuccin-mocha.ron";
      theme = # ron
        ''
          (
            selected_tab: Some("Reset"),
            command_fg: Some("#CDD6F4"),
            selection_bg: Some("#585B70"),
            selection_fg: Some("#cdd6f4"),
            cmdbar_bg: Some("#181825"),
            cmdbar_extra_lines_bg: Some("#181825"),
            disabled_fg: Some("#7f849c"),
            diff_line_add: Some("#a6e3a1"),
            diff_line_delete: Some("#f38ba8"),
            diff_file_added: Some("#a6e3a1"),
            diff_file_removed: Some("#eba0ac"),
            diff_file_moved: Some("#cba6f7"),
            diff_file_modified: Some("#fab387"),
            commit_hash: Some("#b4befe"),
            commit_time: Some("#bac2de"),
            commit_author: Some("#74c7ec"),
            danger_fg: Some("#f38ba8"),
            push_gauge_bg: Some("#89b4fa"),
            push_gauge_fg: Some("#1e1e2e"),
            tag_fg: Some("#f5e0dc"),
            branch_fg: Some("#94e2d5")
          )
        '';
    };

    btop = {
      enable = true;
      settings = {
        color_theme = "catppuccin_mocha.theme";
      };
    };

    eza = {
      enable = true;
      enableFishIntegration = true;
      git = true;
      colors = "auto";
      icons = "auto";
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
          command_timeout = 1500;
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
