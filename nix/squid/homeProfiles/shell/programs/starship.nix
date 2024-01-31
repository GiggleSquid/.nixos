{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib // builtins;
in {
  enable = true;
  enableTransience = true;
  settings =
    {
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
        [│](bold peach) ${lib.concatStrings [
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
        ]}
        [└──](bold peach) $cmd_duration$jobs$battery$os$container$shell$character
      '';

      palette = "catppuccin_mocha";
    }
    // lib.fromTOML (lib.readFile (nixpkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "starship";
        rev = "5629d2356f62a9f2f8efad3ff37476c19969bd4f";
        hash = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
      }
      + /palettes/mocha.toml));
}
