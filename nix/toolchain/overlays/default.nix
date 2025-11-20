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

  google-fonts = nixpkgs.google-fonts.overrideAttrs (old: {
    version = "0-unstable-2025-11-07";
    src = nixpkgs.fetchFromGitHub {
      owner = "google";
      repo = "fonts";
      rev = "4ad8c2096b0507410dac565a0a3cbb37686f216f";
      hash = "sha256-ZEZbqXw79Y2XuTxPyGKUFuHCFQ7jfThYOePyPhvBQ7Y=";
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
              version = "0-unstable-2025-11-11";
              src = nixpkgs.fetchFromGitHub {
                owner = "wez";
                repo = pname;
                rev = "118802c24420f3f4c206333cc7885cd922142e8e";
                fetchSubmodules = true;
                hash = "sha256-omRxmuhWh9YnlsbAd3ZlC/XVoFOwzMHEy5lLXR/cdh8=";
              };
              cargoHash = "sha256-o6VEpAzNUPtONbtI63DXyGWiLDVU9q8IZethlzz5duk=";
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
