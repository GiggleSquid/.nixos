{ inputs }:
let
  inherit (inputs) common nixpkgs;
  inherit (inputs.cells.servers) hardwareProfiles;
  inherit (inputs.cells.squid) nixosSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "nixos-vm";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
  };

  imports =
    let
      profiles = [ hardwareProfiles.vms ];
      suites = lib.concatLists [ nixosSuites.larva ];
    in
    lib.concatLists [
      profiles
      suites
    ];

  system.stateVersion = "25.05";
}
