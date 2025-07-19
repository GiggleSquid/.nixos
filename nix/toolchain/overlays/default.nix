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

  flaresolverr = nixpkgs.flaresolverr.overrideAttrs (old: {
    pname = "flaresolverr";
    version = "3.3.25";
    src = nixpkgs.fetchFromGitHub {
      owner = "FlareSolverr";
      repo = "FlareSolverr";
      rev = "6627de4fa6bc4759b1476085101fc91e80bbe356";
      hash = "sha256-AGRqJOIIePaJH0j0eyMFJ6Kddul3yXF6uw6dPMnskmY=";
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
              version = "0-unstable-2025-03-09";
              src = nixpkgs.fetchFromGitHub {
                owner = "wez";
                repo = pname;
                rev = "a87358516004a652ad840bc1661bdf65ffc89b43";
                fetchSubmodules = true;
                hash = "sha256-aYONqWAJ8oasqWscXMVqbnMuJQjZ+9uL3oeFFUhp7KE=";
              };
              cargoHash = "sha256-f+ARyJJfwHjplAmu2iid++MYQfEs8eDWT5cfkqh1Q94=";
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
