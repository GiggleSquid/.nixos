{
  inputs,
  cell,
}: let
  inherit (inputs) common nixpkgs;
  inherit (cell) machineProfiles hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "timesquid-0";
in {
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
  };

  imports = let
    profiles = [
      hardwareProfiles.servers
      machineProfiles.timesquid-0
    ];
    suites = with serverSuites;
      lib.concatLists [
        nixosSuites.server
        ntp-server
      ];
  in
    lib.concatLists [profiles suites];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users = {
      squid = {
        imports = let
          modules = [];
          profiles = [];
          suites = with homeSuites; squid;
        in
          lib.concatLists [modules profiles suites];
        home.stateVersion = "23.05";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "23.05";
      };
    };
  };

  system.stateVersion = "23.05";
}
