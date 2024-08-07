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
  hostName = "squid-rig";
  ip = "10.10.0.10/24";
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

  services = {
    xserver.xkb = lib.mkForce {
      layout = "us";
      variant = "colemak_dh_wide_iso";
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles."${hostName}"
        machineProfiles.squid-rig
      ];
      suites =
        with nixosSuites;
        lib.concatLists [
          desktop
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
