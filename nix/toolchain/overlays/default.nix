{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.cells.toolchain) pkgs packages;
in
{
  google-fonts = nixpkgs.google-fonts.overrideAttrs (old: {
    version = "0-unstable-2026-02-27";
    src = nixpkgs.fetchFromGitHub {
      owner = "google";
      repo = "fonts";
      rev = "c8e45997f999c1b23a812d4706df464c13ee8861";
      hash = "sha256-8uPUf9dSQTDa08J6+kZHjWvh5rHX1REQq7LkhQoCktg=";
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
