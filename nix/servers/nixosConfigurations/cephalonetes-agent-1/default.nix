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
    hostName = "agent-1";
    domain = "cephalonetes.lan.gigglesquid.tech";
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = lib.mkForce "en*18";
        networkConfig = {
          Address = "10.10.4.41/24";
          Gateway = "10.10.4.1";
        };
      };
      "20-lan" = {
        matchConfig.Name = "en*19";
        networkConfig = {
          Address = "10.10.5.41/24";
          Gateway = "10.10.5.1";
          DHCP = "no";
        };
        dns = [ "10.10.5.1" ];
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
  };

  services = {
    openiscsi = {
      enable = true;
      name = "iqn.2023-01.tech.gigglesquid.lan.iscsi:agent-1";
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.cephalonetes ];
      suites =
        with k3sSuites;
        lib.concatLists [
          nixosSuites.server
          agent-suite
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
            suites = with homeSuites; lib.concatLists [ squid ];
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
