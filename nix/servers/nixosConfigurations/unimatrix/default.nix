{ inputs, cell }:
let
  inherit (inputs) common nixpkgs;
  inherit (cell) machineProfiles hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "unimatrix";
  ip = "10.3.1.27/23";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    useNetworkd = true;
    timeServers = [ "10.3.0.5" ];
    firewall = {
      allowedTCPPorts = [ ];
    };
  };
  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        matchConfig.Name = "en*";
        networkConfig = {
          Address = ip;
          DHCP = "no";
        };
        gateway = [ "10.3.0.1" ];
        dns = [ "10.3.0.1" ];

        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  services.borgbackup.repos = {
    squid-rig = {
      path = "/mnt/borg/repos/squid-rig_borg";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkE7ErVvMkeIHhAMl4zoQ8N2IhvEOl1+4zgFLFb16Pi"
      ];
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.unimatrix ];
      suites = lib.concatLists [ nixosSuites.server ];
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
