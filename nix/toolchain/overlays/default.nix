{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.toolchain) pkgs packages;
in
{
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
              version = "0-unstable-2026-01-17";
              src = nixpkgs.fetchFromGitHub {
                owner = "wez";
                repo = pname;
                rev = "05343b387085842b434d267f91b6b0ec157e4331";
                fetchSubmodules = true;
                hash = "sha256-V6WvkNZryYofarsyfcmsuvtpNJ/c3O+DmOKNvoYPbmA=";
              };
              cargoHash = "sha256-waXq0U2Ud7FhlJn3evO7bZSBsOAA39ObiVWHycNQXmA=";
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
