{
  inputs,
  cell,
}: let
  common = {
    bee = {
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs;
    };
    deployment = {
      allowLocalDeployment = false;
      buildOnTarget = false;
      tags = ["all" "servers"];
    };
  };
in
  inputs.hive.findLoad {
    inherit cell;
    inputs = inputs // {inherit common;};
    block = ./.;
  }
