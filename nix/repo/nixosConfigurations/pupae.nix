{ inputs }:
let
  inherit (inputs) commonFixed-25_11 nixpkgs;
  inherit (inputs.cells.servers) hardwareProfiles;
  inherit (inputs.cells.squid) nixosSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "nixos-vm";
in
{
  inherit (commonFixed-25_11) bee time;
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

  system.stateVersion = "25.11";
}
