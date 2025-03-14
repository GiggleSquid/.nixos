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
                rev = "12b971ac44738f37c120160da165cd9072c0e6d2";
                fetchSubmodules = true;
                hash = "sha256-AJ//9O1Sbo0FqU0C2ZUMD9VTk/IP+uMZU1Cx+Tra2Jo=";
              };
              cargoHash = "sha256-ndvdnCl5rVtP6tkcVewiRyNAiM5drEoQbb7FvDGfV3A=";
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
