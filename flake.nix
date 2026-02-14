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
              "discord"
              "vintagestory"
              "starsector"
              "rar"
              "minecraft-server"
              "Oracle_VirtualBox_Extension_Pack"
              "castlabs-electron"
              "unrar"
            ];
          permittedInsecurePackages = [ ];
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
      follows = "nixpkgs-unstable";
    };

    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable-small";
    };

    nixpkgs-25_11 = {
      url = "github:nixos/nixpkgs/nixos-25.11-small";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-pia-vpn = {
      url = "github:rcambrj/nix-pia-vpn";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arion = {
      url = "github:hercules-ci/arion";
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

    flake-utils.url = "github:numtide/flake-utils";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell = {
      url = "github:numtide/devshell";
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

    nix-topology = {
      url = "github:oddlama/nix-topology";
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
      "https://nix-cache.lan.gigglesquid.tech"
      "https://local.nix-cache.lan.gigglesquid.tech/attic"
    ];
    extra-trusted-public-keys = [
      "nix-cache.lan.gigglesquid.tech:sQW0gKIG9hooFPBoFDoiDbToJXPhFWpTI4NqNY1MYaA="
      "attic:4reipGK1ubbnLAmGWWtjD2bpuqSWTEsaYuREMEcz7Ro="
    ];
  };
}
