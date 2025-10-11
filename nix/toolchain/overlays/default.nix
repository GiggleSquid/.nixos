{ inputs, cell }:
let
  inherit (inputs) nixpkgs nixos-hardware;
  inherit (inputs.cells.toolchain) pkgs packages;
in
{
  deviceTree = nixpkgs.deviceTree // {
    applyOverlays =
      nixpkgs.callPackage "${nixos-hardware.nixosModules.raspberry-pi-4}/apply-overlays-dtmerge.nix"
        { };
  };

  ladybird = nixpkgs.ladybird.overrideAttrs (old: {
    version = "0-unstable-2024-08-30";
    src = nixpkgs.fetchFromGitHub {
      owner = "LadybirdWebBrowser";
      repo = "ladybird";
      rev = "92a37b3b1a62cf8ed6bc942229cb77bce01ec815";
      hash = "sha256-IU48PBOe9mNtPNVVq+XfUVeh/nKmULSZBkaPld/510w=";
    };
  });

  # wezterm 'nightly'
  wezterm = nixpkgs.wezterm.override (
    let
      rustPlatform' = nixpkgs.makeRustPlatform {
        rustc = pkgs.rust-bin.stable.latest.minimal;
        cargo = pkgs.rust-bin.stable.latest.minimal;
      };
    in
    {
      rustPlatform = rustPlatform' // {
        buildRustPackage =
          args:
          rustPlatform'.buildRustPackage (
            args
            // rec {
              pname = "wezterm";
              version = "0-unstable-2025-07-13";
              src = nixpkgs.fetchFromGitHub {
                owner = "wez";
                repo = pname;
                rev = "85c587f9f3d8be49dfa252da116fc9ca290df113";
                fetchSubmodules = true;
                hash = "sha256-hyyKC5BXeIbgP+bXxtvIz1LZUDoUJ6+em/PrX/TEg4k=";
              };
              cargoHash = "sha256-chMbDMT8UWaiGovlzYn1UD8VFqb9UYHMDDx/A62wQsY=";
            }
          );
      };
    }
  );

  # https://github.com/NixOS/nixpkgs/issues/287646
  kdePackages = nixpkgs.kdePackages // {
    sddm = nixpkgs.kdePackages.sddm.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (nixpkgs.fetchpatch {
          url = "https://patch-diff.githubusercontent.com/raw/sddm/sddm/pull/1779.patch";
          hash = "sha256-8QP9Y8V9s8xrc+MIUlB7iHVNHbntGkw0O/N510gQ+bE=";
        })
      ];
    });
  };

}
