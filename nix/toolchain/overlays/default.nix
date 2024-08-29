{ inputs, cell }:
let
  inherit (inputs) nixpkgs nixos-hardware nixpkgs-flaresolverr-chromium-126;
  inherit (inputs.cells.toolchain) pkgs packages;
in
{
  deviceTree = nixpkgs.callPackage nixos-hardware.apply-overlays-dtmerge { };

  py-natpmp = packages.py-natpmp;

  # wezterm 'nightly'
  wezterm = nixpkgs.wezterm.override (
    let
      rustPlatform = nixpkgs.makeRustPlatform {
        rustc = pkgs.rust-bin.stable.latest.minimal;
        cargo = pkgs.rust-bin.stable.latest.minimal;
      };
    in
    old: {
      rustPlatform = old.rustPlatform // {
        buildRustPackage =
          args:
          rustPlatform.buildRustPackage (
            args
            // rec {
              pname = "wezterm";
              version = "30345b36d8a00fed347e4df5dadd83915a7693fb";
              src = nixpkgs.fetchFromGitHub {
                owner = "wez";
                repo = pname;
                rev = version;
                fetchSubmodules = true;
                hash = "sha256-By7g1yImmuVba/MTcB6ajNSHeWDRn4gO+p0UOWcCEgE=";
              };

              postPatch = ''
                cp ${./wezterm/Cargo.lock} Cargo.lock

                echo ${version} > .tag

                # tests are failing with: Unable to exchange encryption keys
                rm -r wezterm-ssh/tests
              '';

              cargoLock = {
                lockFile = ./wezterm/Cargo.lock;
                outputHashes = {
                  "sqlite-cache-0.1.3" = "sha256-sBAC8MsQZgH+dcWpoxzq9iw5078vwzCijgyQnMOWIkk=";
                  "xcb-imdkit-0.3.0" = "sha256-77KaJO+QJWy3tJ9AF1TXKaQHpoVOfGIRqteyqpQaSWo=";
                };
              };
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
