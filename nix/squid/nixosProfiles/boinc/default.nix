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
      user = "GiggleSquid_GRC_71c3092ca4536ee0f0e351e98bf57b31";
      extraArgs = [ ];
    };
  };
}
