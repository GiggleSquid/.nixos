{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.toolchain) pkgs packages;
in
{
  google-fonts = nixpkgs.google-fonts.overrideAttrs (old: {
    version = "0-unstable-2026-02-13";
    src = nixpkgs.fetchFromGitHub {
      owner = "google";
      repo = "fonts";
      rev = "113eb7cbd7958cdbda9a7670d78aae527bbb149a";
      hash = "sha256-+vFuH1EbrmwlcfIRd4bVqhcGgfdGTEeXpnoWM4C8u4I=";
    };
  });

  gridcoin-research = nixpkgs.gridcoin-research.overrideAttrs (old: {
    patches = [
      (nixpkgs.fetchpatch2 {
        url = "https://github.com/gridcoin-community/Gridcoin-Research/commit/bab91e95ca8c83f06dcc505e6b3f8b44dc6d50d4.patch";
        sha256 = "sha256-GzurVlR7Tk3pmQfgO9WtHXjX6xHqNzdYqOdbJND7MpA=";
      })
    ];
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
