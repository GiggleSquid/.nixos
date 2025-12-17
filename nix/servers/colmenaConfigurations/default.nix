{ inputs, cell }:
let
  common = {
    bee = {
      system = "x86_64-linux";
      # pkgs = inputs.nixpkgs;
      pkgs = inputs.cells.toolchain.pkgs;
    };
    deployment = {
      allowLocalDeployment = false;
      buildOnTarget = false;
      tags = [
        "all"
        "servers"
      ];
    };
  };
  rpi = {
    bee = {
      system = "aarch64-linux";
      pkgs = inputs.cells.toolchain.pkgs;
    };
    deployment = {
      allowLocalDeployment = false;
      buildOnTarget = true;
      tags = [
        "all"
        "servers"
      ];
    };
  };
in
inputs.hive.findLoad {
  inherit cell;
  inputs = inputs // {
    inherit common rpi;
  };
  block = ./.;
}
