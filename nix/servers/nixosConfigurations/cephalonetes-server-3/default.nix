{ inputs, cell }:
let
  inherit (inputs) common nixpkgs self;
  inherit (cell) hardwareProfiles k3sSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
in
{
  inherit (common) bee time;
  networking = {
    hostName = "server-3";
    domain = "cephalonetes.lan.gigglesquid.tech";
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        networkConfig = {
          Address = "10.10.4.33/24";
          Gateway = "10.10.4.1";
        };
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
  };

  services = {
    openiscsi = {
      enable = true;
      name = "iqn.2023-01.tech.gigglesquid.lan.iscsi:server-3";
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.cephalonetes ];
      suites =
        with k3sSuites;
        lib.concatLists [
          nixosSuites.server
          server-suite
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
            suites = with homeSuites; squid;
          in
          lib.concatLists [ suites ];
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
