{ inputs, cell }:
let
  inherit (inputs) common nixpkgs;
  inherit (cell)
    machineProfiles
    hardwareProfiles
    nixosSuites
    homeSuites
    ;
  lib = nixpkgs.lib // builtins;
  hostName = "squid-top";
  ip = "10.10.0.11/24";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
  };
  systemd.network = {
    networks = {
      "10-lan" = {
        networkConfig = {
          Address = ip;
        };
      };
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles."${hostName}"
        machineProfiles."${hostName}"
      ];
      suites =
        with nixosSuites;
        lib.concatLists [
          laptop
          plasma6
        ];
    in
    lib.concatLists [
      profiles
      suites
    ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users = {
      squid = {
        imports =
          let
            modules = [ ];
            profiles = [ ];
            suites =
              with homeSuites;
              lib.concatLists [
                squid
                plasma6
              ];
          in
          lib.concatLists [
            modules
            profiles
            suites
          ];
        home.stateVersion = "23.11";
      };
    };
  };

  system.stateVersion = "23.11";
}
