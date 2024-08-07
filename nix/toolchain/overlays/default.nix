{ inputs, cell }:
let
  inherit (inputs) nixpkgs nixos-hardware;
  inherit (inputs.cells.toolchain) pkgs;
in
{
  deviceTree = nixpkgs.callPackage nixos-hardware.apply-overlays-dtmerge { };

  google-fonts = nixpkgs.google-fonts.overrideAttrs (
    old: with nixpkgs; {
      version = "unstable-2024-06-14";
      src = fetchFromGitHub {
        owner = "google";
        repo = "fonts";
        rev = "4d015b57411aa9dfddb89655670b3f2a2834419e";
        hash = "sha256-5tKtUKIp9A8ipBhoaof+B28k8boppxnUm26uvi0k2UM=";
      };
    }
  );

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
              version = "7e8fdc118d2d7ceb51c720a966090f6cb65089b7";
              src = nixpkgs.fetchFromGitHub {
                owner = "wez";
                repo = pname;
                rev = version;
                fetchSubmodules = true;
                hash = "sha256-8j7044lN0w/uVQOvqq/GlDGATmI3zAk/GTndJEyb3Ws=";
              };

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
