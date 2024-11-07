{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with nixpkgs; [ ];
}
