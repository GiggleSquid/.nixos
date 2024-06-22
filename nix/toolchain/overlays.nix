{ inputs, cell }:
let
  inherit (inputs) nixpkgs nixos-hardware;
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

}
