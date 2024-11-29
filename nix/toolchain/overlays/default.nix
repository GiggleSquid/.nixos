{ inputs, cell }:
let
  inherit (inputs)
    nixpkgs
    nixos-hardware
    nixpkgs-flaresolverr-chromium-126
    nixos-caddy-with-plugins
    ;
  inherit (inputs.cells.toolchain) pkgs packages;
in
{
  deviceTree = nixpkgs.callPackage nixos-hardware.apply-overlays-dtmerge { };

  qbittorrent-enhanced-nox = packages.qbittorrent-enhanced.override { guiSupport = false; };

  py-natpmp = packages.py-natpmp;

  odoo = packages.odoo;

  website_maf = packages.website_maf;
  product_brand_sale = packages.product_brand_sale;
  product_brand_ecommerce = packages.product_brand_ecommerce;

  caddy = nixos-caddy-with-plugins.packages.default;

  ladybird = nixpkgs.ladybird.overrideAttrs (old: {
    version = "0-unstable-2024-08-30";
    src = nixpkgs.fetchFromGitHub {
      owner = "LadybirdWebBrowser";
      repo = "ladybird";
      rev = "92a37b3b1a62cf8ed6bc942229cb77bce01ec815";
      hash = "sha256-IU48PBOe9mNtPNVVq+XfUVeh/nKmULSZBkaPld/510w=";
    };
  });

  lego = nixpkgs.lego.overrideAttrs (old: {
    version = "unstable-2024-09-07";
    src = nixpkgs.fetchFromGitHub {
      owner = "go-acme";
      repo = "lego";
      rev = "75b910b296eb9ba97032e4ccc87fb032901c8c6e";
      sha256 = "sha256-1wu0L99hIix5kC9bZwN2R4rj7w7a0VP3cOMN1x216xU=";
    };
    vendorHash = "sha256-eI8VmGXlBwISyBDUbgHPdZw12e7a1SlxXthHcaOPYsU=";
  });

  # https://github.com/NixOS/nixpkgs/issues/332776
  pkgs-flaresolverr-chromium-126 = import nixpkgs-flaresolverr-chromium-126 {
    inherit (cell.pkgs) system;
  };

  # selenium-manager = nixpkgs.selenium-manager.override (old: {
  #   rustPlatform = old.rustPlatform // {
  #     buildRustPackage =
  #       args:
  #       old.rustPlatform.buildRustPackage (
  #         args
  #         // rec {
  #           version = "4.24.0";
  #           src = nixpkgs.fetchFromGitHub {
  #             owner = "SeleniumHQ";
  #             repo = "selenium";
  #             rev = "selenium-${version}";
  #             hash = "sha256-AsQr9kGv2dxkiFzptDA0D27OXZjYj7oDKz2oEQ2qW7s=";
  #           };
  #           cargoHash = "sha256-mirEeOi6CfKjb8ZuqardJeYy9EGnpsw5fkUw7umhkro=";
  #         }
  #       );
  #   };
  # });

  # pythonPackagesExtensions = nixpkgs.pythonPackagesExtensions ++ [
  #   (python-final: python-prev: {
  #     selenium = python-prev.selenium.overridePythonAttrs (old: rec {
  #       pname = "selenium";
  #       version = "4.24.0";
  #       src = nixpkgs.fetchFromGitHub {
  #         owner = "SeleniumHQ";
  #         repo = "selenium";
  #         # check if there is a newer tag with or without -python suffix
  #         rev = "refs/tags/selenium-${version}";
  #         hash = "sha256-AsQr9kGv2dxkiFzptDA0D27OXZjYj7oDKz2oEQ2qW7s=";
  #       };
  #       patches = [
  #         (./. + "/selenium/remove-rust-bindings.patch")
  #       ];
  #     });
  #   })
  # ];

  i2pd = nixpkgs.i2pd.overrideAttrs (old: rec {
    pname = "i2pd";
    version = "2.53.1";
    src = nixpkgs.fetchFromGitHub {
      owner = "PurpleI2P";
      repo = pname;
      rev = version;
      sha256 = "sha256-dt1lem8i5wcoBJyEKSBjMkyUKUKvVSUpfyhDsoeea/A=";
    };
    patches = [ ];
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
              version = "a7ff718c7c182d62d7c848187da1655e58b8ecd8";
              src = nixpkgs.fetchFromGitHub {
                owner = "wez";
                repo = pname;
                rev = version;
                fetchSubmodules = true;
                hash = "sha256-+m2bZlhi0wx4KTqEikcKL7+YN+t8FLfrb5aeiQOQtGM=";
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
