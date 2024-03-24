{ inputs, cell }:
let
  common = {
    hardware = {
      enableRedistributableFirmware = true;
    };
  };
in
inputs.hive.findLoad {
  inherit cell;
  inputs = inputs // {
    inherit common;
  };
  block = ./.;
}
