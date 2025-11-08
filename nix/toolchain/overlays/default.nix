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
              version = "0-unstable-2025-10-05";
              src = nixpkgs.fetchFromGitHub {
                owner = "wez";
                repo = pname;
                rev = "b6e75fd7c8f9c9ad5af4efbba1d28df0969f6b17";
                fetchSubmodules = true;
                hash = "sha256-t99sVnRzfJUa6b6h55nFy/Xpkeeeph5ugZBl98N0jEg=";
              };
              cargoHash = "sha256-QjYxDcWTbLTmtQEK6/ujwaDwdY+4C6EIOZ8I0hYIx00=";
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
