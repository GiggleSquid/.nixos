{ inputs, cell }:
let
  common = {
    bee = {
      system = "x86_64-linux";
      pkgs = inputs.cells.toolchain.pkgs;
      home = inputs.home-manager;
    };
    time.timeZone = "Europe/London";
  };
in
inputs.hive.findLoad {
  inherit cell;
  inputs = inputs // {
    inherit common;
  };
  block = ./.;
}
