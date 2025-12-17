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
      profiles = [ hardwareProfiles.rpi4 ];
      suites = lib.concatLists [ nixosSuites.larva ];
    in
    lib.concatLists [
      profiles
      suites
    ];

  system.stateVersion = "26.05";
}
