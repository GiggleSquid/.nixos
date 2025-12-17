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
  commonFixed-25_11 = {
    bee = {
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs-25_11 {
        inherit (inputs.nixpkgs) system;
      };
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
    inherit common commonFixed-25_11 rpi;
  };
  block = ./.;
}
