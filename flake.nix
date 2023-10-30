{
  description = "The Squid Hive";

  outputs = {
    self,
    hive,
    std,
    ...
  } @ inputs: let
    myCollect =
      hive.collect
      // {
        renamer = cell: target:
          if cell == "squid" || cell == "repo"
          then "${target}"
          else "${cell}-${target}";
      };
    lib = inputs.nixpkgs.lib // builtins;
  in
    hive.growOn {
      inherit inputs;

      cellsFrom = ./nix;

      cellBlocks = with std.blockTypes;
      with hive.blockTypes; [
        (devshells "devshells")

        (functions "homeModules")

        (functions "nixosSuites")
        (functions "homeSuites")

        (functions "hardwareProfiles")
        (functions "nixosProfiles")
        (functions "userProfiles")
        (functions "homeProfiles")

        nixosConfigurations
        colmenaConfigurations
      ];

      nixpkgsConfig.allowUnfreePredicate = pkg:
        lib.elem (lib.getName pkg) [
          "steam"
          "steam-run"
          "steam-original"
          "nvidia-x11"
          "nvidia-settings"
          "discord"
          "vintagestory"
        ];
    }
    {
      devShells = hive.harvest self ["repo" "devshells"];
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

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
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
      "https://anyrun.cachix.org"
      "https://colmena.cachix.org"
      "https://helix.cachix.org"
      "https://hyprland.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
