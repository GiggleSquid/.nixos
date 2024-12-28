{
  description = "The Squid Hive";

  outputs =
    {
      self,
      hive,
      std,
      ...
    }@inputs:
    let
      myCollect = hive.collect // {
        renamer =
          cell: target: if cell == "squid" || cell == "repo" then "${target}" else "${cell}-${target}";
      };
      lib = inputs.nixpkgs.lib // builtins;
    in
    hive.growOn
      {
        inherit inputs;

        cellsFrom = ./nix;

        cellBlocks =
          with std.blockTypes;
          with hive.blockTypes;
          [
            (devshells "devshells")

            (pkgs "pkgs")
            (pkgs "overlays")

            (installables "packages")

            (functions "nixosModules")
            (functions "homeModules")

            (functions "nixosSuites")
            (functions "homeSuites")
            (functions "serverSuites")
            (functions "k3sSuites")

            (functions "machineProfiles")
            (functions "hardwareProfiles")
            (functions "nixosProfiles")
            (functions "userProfiles")
            (functions "homeProfiles")
            (functions "k3sProfiles")

            nixosConfigurations
            colmenaConfigurations
          ];

        nixpkgsConfig = {
          allowUnfreePredicate =
            pkg:
            lib.elem (lib.getName pkg) [
              "steam"
              "steam-run"
              "steam-original"
              "steam-unwrapped"
              "nvidia-x11"
              "nvidia-settings"
              "discord"
              "vintagestory"
              "starsector"
              "rar"
              "minecraft-server"
              "Oracle_VirtualBox_Extension_Pack"
            ];
          permittedInsecurePackages = [
            # vintagestory
            "dotnet-runtime-wrapped-7.0.20"
            "dotnet-runtime-7.0.20"

            # arrs
            # https://github.com/Radarr/Radarr/pull/10258
            # https://github.com/Prowlarr/Prowlarr/pull/2195
            # https://github.com/Sonarr/Sonarr/issues/7442
            # https://github.com/Sonarr/Sonarr/pull/6776
            "aspnetcore-runtime-wrapped-6.0.36"
            "aspnetcore-runtime-6.0.36"
            "dotnet-sdk-wrapped-6.0.428"
            "dotnet-sdk-6.0.428"
          ];
        };
      }
      {
        devShells = hive.harvest self [
          "repo"
          "devshells"
        ];
      }
      {
        nixosConfigurations = myCollect self "nixosConfigurations";
        colmenaHive = myCollect self "colmenaConfigurations";

        # Might work on this. Atm I just import the modules in the nixosConfiguration for the machine
        # hmModules = hive.collect self "homeModules";
      };

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    nixpkgs-flaresolverr-chromium-126 = {
      url = "github:nixos/nixpkgs/ebbc0409688869938bbcf630da1c1c13744d2a7b";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kubenix = {
      url = "github:hall/kubenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixago = {
      url = "github:nix-community/nixago";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    std = {
      url = "github:divnix/std";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        devshell.follows = "devshell";
        devshell.inputs.nixpkgs.follows = "nixpkgs";
        nixago.follows = "nixago";
      };
    };

    hive = {
      url = "github:divnix/hive";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        colmena.follows = "colmena";
        nixago.follows = "nixago";
      };
    };
  };

  nixConfig = {
    extra-experimental-features = "nix-command flakes";

    extra-substituters = [
      "https://colmena.cachix.org"
      "https://helix.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
