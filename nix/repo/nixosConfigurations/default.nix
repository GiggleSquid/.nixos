{ inputs, cell }:
let
  common = {
    bee = {
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs;
      home = inputs.home-manager;
    };
    time.timeZone = "Europe/London";
  };
  rpi = {
    bee = {
      system = "aarch64-linux";
      pkgs = inputs.nixpkgs;
      home = inputs.home-manager;
    };
    time.timeZone = "Europe/London";
  };

in
inputs.hive.findLoad {
  inherit cell;
  inputs = inputs // {
    inherit common;
    inherit rpi;
  };
  block = ./.;
}
