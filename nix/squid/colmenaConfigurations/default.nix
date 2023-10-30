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
      allowLocalDeployment = true;
      buildOnTarget = true;
      tags = ["all"];
    };
  };
in
  inputs.hive.findLoad {
    inherit cell;
    inputs = inputs // {inherit common;};
    block = ./.;
  }
