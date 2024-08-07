{ inputs, cell }:
let
  inherit (inputs) rpi nixpkgs;
  inherit (cell) machineProfiles hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "ns1";
in
{
  inherit (rpi) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    nameservers = [ "127.0.0.1" ];
    timeServers = [ "10.3.0.5" ];
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = lib.mkForce "end0";
        networkConfig = {
          DHCP = "no";
          Address = "10.3.0.11/23";
          Gateway = "10.3.0.1";
        };
        dns = [ "127.0.0.1" ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles.ns1
        machineProfiles.ns1
      ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          dns-server
          rpi-server
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
        home.stateVersion = "24.11";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "24.11";
      };
    };
  };

  system.stateVersion = "24.11";
}
