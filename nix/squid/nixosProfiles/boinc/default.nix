{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  services.boinc = {
    enable = true;
    extraEnvPackages = with nixpkgs; [
      virtualbox
      ocl-icd
    ];
  };
}
