{ inputs }:
let
  inherit (inputs) common nixpkgs;
  inherit (inputs.cells.servers) hardwareProfiles nixosProfiles;
  inherit (inputs.cells.squid) nixosSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "nixos-lxc";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
  };

  imports =
    let
      profiles = [
        hardwareProfiles.servers
        nixosProfiles.common
      ];
      suites = with nixosSuites; larva;
    in
    lib.concatLists [
      profiles
      suites
    ];

  system.stateVersion = "25.05";
}
