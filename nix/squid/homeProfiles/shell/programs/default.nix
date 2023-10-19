{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
in {
  fish = {
    enable = true;
    interactiveShellInit = ''${lib.getExe nixpkgs.starship} init fish | source'';
    functions = {
      starship_transient_rprompt_func = ''
        starship module time
      '';
    };
    plugins = [
      {
        name = "sponge";
        src = nixpkgs.fishPlugins.sponge.src;
      }
      {
        name = "colored-man-pages";
        src = nixpkgs.fishPlugins.colored-man-pages.src;
      }
      {
        name = "z";
        src = nixpkgs.fishPlugins.z.src;
      }
    ];
  };

  bash = {
    enable = true;
  };

  k9s = {
    enable = true;
  };

  lsd = {
    enable = true;
    enableAliases = true;
    settings = {
      total-size = true;
    };
  };

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
          truncation_length = 5;
          truncation_symbol = ".../";
          truncate_to_repo = false;
          style = "bold lavender";
          format = "in [$path]($style)[$read_only]($read_only_style)";
          before_repo_root_style = "dimmed lavender";
          repo_root_style = "bold lavender";
          repo_root_format = "in [$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style)";
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
        shell = {
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
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$localip"
          "$sudo"
          "$shlvl"
          "$singularity"
          "$kubernetes"
          "$directory"
          "$line_break"
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
          "$line_break"
          "$cmd_duration"
          "$jobs"
          "$battery"
          # "$time"
          "$os"
          "$container"
          "$shell"
          "$character"
        ];
        palette = "catppuccin_mocha";
      }
      // builtins.fromTOML (builtins.readFile (nixpkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "starship";
          rev = "5629d2356f62a9f2f8efad3ff37476c19969bd4f";
          hash = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
        }
        + /palettes/mocha.toml));
  };
}
