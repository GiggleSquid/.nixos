{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  services.boinc = {
    enable = true;
    extraEnvPackages = with nixpkgs; [
      libglvnd
      brotli
      ocl-icd
    ];
  };
}
