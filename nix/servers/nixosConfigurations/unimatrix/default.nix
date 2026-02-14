{ inputs, cell }:
let
  inherit (inputs) common nixpkgs;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "unimatrix";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [ ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp5s0";
        ipv6AcceptRAConfig = {
          Token = "static:::1:27";
        };
        address = [
          "10.3.1.27/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  services = {
    borgbackup.repos = {
      squid-rig = {
        path = "/mnt/borg/repos/squid-rig_borg";
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkE7ErVvMkeIHhAMl4zoQ8N2IhvEOl1+4zgFLFb16Pi"
        ];
      };
      squid-top = {
        path = "/mnt/borg/repos/squid-top_borg";
        authorizedKeys = [ "" ];
      };
    };

    alloy-squid = {
      enable = true;
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.unimatrix ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          base
        ];
    in
    lib.concatLists [
      profiles
      suites
    ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "hm-bak";
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
        home.stateVersion = "25.05";
      };
      nixos = {
        imports = with homeSuites; nixos;
        home.stateVersion = "25.05";
      };
    };
  };

  system.stateVersion = "25.05";
}
