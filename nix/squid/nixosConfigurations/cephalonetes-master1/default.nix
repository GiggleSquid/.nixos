{
  inputs,
  cell,
}: let
  inherit (inputs) common nixpkgs;
  inherit (cell) hardwareProfiles nixosProfiles nixosSuites homeProfiles homeSuites homeModules;
  lib = nixpkgs.lib // builtins;
  hostName = "master-1";
in {
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "cephalonas.lan.gigglesquid.tech";
  };

  imports = let
    profiles = with nixosProfiles; [
      hardwareProfiles.cephalonetes
    ];
    suites = with nixosSuites; server;
  in
    lib.concatLists [profiles suites];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users = {
      squid = {
        imports = let
          modules = with homeModules; [
          ];
          profiles = with homeProfiles; [
          ];
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
