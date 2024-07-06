{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  environment.systemPackages = with nixpkgs; [
    unzip
    rar
    p7zip
  ];

}
