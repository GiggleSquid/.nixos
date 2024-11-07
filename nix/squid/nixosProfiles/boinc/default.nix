{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  services = {
    boinc = {
      enable = true;
      extraEnvPackages = with nixpkgs; [
        virtualbox
        libglvnd
        brotli
        ocl-icd
      ];
    };
    foldingathome = {
      enable = true;
      team = 226804;
      user = null;
      extraArgs = [ ];
    };
  };
}
