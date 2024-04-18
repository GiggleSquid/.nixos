{ inputs }:
let
  inherit (inputs) common nixpkgs;
  inherit (inputs.cells.servers) hardwareProfiles k3sProfiles;
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
        k3sProfiles.common
      ];
      suites = with nixosSuites; larva;
    in
    lib.concatLists [
      profiles
      suites
    ];

  system.stateVersion = "24.05";
}
