{ inputs, cell }:
let
  inherit (inputs) nixpkgs nixos-hardware;
  inherit (inputs.cells.toolchain) pkgs packages;
in
{
  deviceTree = nixpkgs.callPackage nixos-hardware.apply-overlays-dtmerge { };

  qbittorrent-enhanced-nox = packages.qbittorrent-enhanced.override { guiSupport = false; };

  odoo = packages.odoo;

  website_maf = packages.website_maf;
  product_brand_sale = packages.product_brand_sale;
  product_brand_ecommerce = packages.product_brand_ecommerce;

  ladybird = nixpkgs.ladybird.overrideAttrs (old: {
    version = "0-unstable-2024-08-30";
    src = nixpkgs.fetchFromGitHub {
      owner = "LadybirdWebBrowser";
      repo = "ladybird";
      rev = "92a37b3b1a62cf8ed6bc942229cb77bce01ec815";
      hash = "sha256-IU48PBOe9mNtPNVVq+XfUVeh/nKmULSZBkaPld/510w=";
    };
  });

  i2pd = nixpkgs.i2pd.overrideAttrs (old: rec {
    pname = "i2pd";
    version = "0-unstable-2025-02-03";
    src = nixpkgs.fetchFromGitHub {
      owner = "PurpleI2P";
      repo = pname;
      rev = "ef19a85fc099277eef1e0f36e5a25df0c665b547";
      sha256 = "sha256-m9aI0LzRitP/9hQIlYZ4h9Gayqi+iDW3I4dJFjOZYkg=";
    };
  });

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
              version = "ee0c04e735fb94cb5119681f704fb7fa6731e713";
              src = nixpkgs.fetchFromGitHub {
                owner = "wez";
                repo = pname;
                rev = version;
                fetchSubmodules = true;
                hash = "sha256-0jqnSzzfg8ecBaayJI8oP9X0FyijFFT3LA6GKfpAFwI=";
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
