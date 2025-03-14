{ inputs }:
let
  inherit (inputs) rpi nixpkgs;
  inherit (inputs.cells.servers) hardwareProfiles;
  inherit (inputs.cells.squid) nixosSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "nixos-rpi";
in
{
  inherit (rpi) bee time;
  networking = {
    inherit hostName;
  };

  imports =
    let
      profiles = [
        hardwareProfiles.rpi4
      ];
      suites = with nixosSuites; larva;
    in
    lib.concatLists [
      profiles
      suites
    ];

  system.stateVersion = "25.05";
}
