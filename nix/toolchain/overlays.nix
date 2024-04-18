{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{

  # Example usage with rke2 overlay

  # rke2 = (
  #   nixpkgs.callPackage "${nixpkgs.path}/pkgs/applications/networking/cluster/rke2" {
  #     buildGoModule =
  #       args:
  #       nixpkgs.buildGo121Module (
  #         args
  #         // rec {
  #           pname = "rke2";
  #           version = "1.29.2+rke2r1";
  #           src = nixpkgs.fetchFromGitHub {
  #             owner = "rancher";
  #             repo = pname;
  #             rev = "v${version}";
  #             hash = "sha256-rB4XqiFTW7y2CD2CRMkCGu3noHQZfibA7iKdXbAzqWY=";
  #           };
  #         }
  #       );
  #   }
  # );
}
