{ inputs }:
let
  inherit (inputs) common nixpkgs;
  inherit (inputs.cells.cephalonetes) hardwareProfiles rke2Profiles;
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
      profiles = [
        hardwareProfiles.cephalonetes
        rke2Profiles.common
      ];
      suites = with nixosSuites; larva;
    in
    lib.concatLists [
      profiles
      suites
    ];

  system.stateVersion = "23.05";
}
