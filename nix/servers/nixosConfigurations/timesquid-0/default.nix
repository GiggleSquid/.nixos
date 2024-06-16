{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) rpi nixpkgs self;
  inherit (cell) machineProfiles hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "timesquid-0";
in
{

  sops.secrets.wifi_env = {
    sopsFile = "${self}/sops/squid-rig.yaml";
  };

  inherit (rpi) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    # wireless = {
    #   enable = true;
    #   environmentFile = config.sops.secrets.wifi_env.path;
    #   networks = {
    #     "@WIFI_SSID@" = {
    #       psk = "@WIFI_PSK@";
    #     };
    #   };
    # };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        networkConfig = {
          Address = "10.10.3.5/24";
          Gateway = "10.10.3.1";
        };
      };
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles.servers-rpi
        machineProfiles.timesquid-0
      ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          ntp-server
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
            suites = with homeSuites; squid;
          in
          lib.concatLists [
            modules
            profiles
            suites
          ];
        home.stateVersion = "24.05";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "24.05";
      };
    };
  };

  system.stateVersion = "24.05";
}
