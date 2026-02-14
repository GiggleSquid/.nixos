{ inputs, cell }:
let
  inherit (inputs) common nixpkgs self;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites nixosProfiles;
  lib = nixpkgs.lib // builtins;
  hostName = "boinc";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "tentacle0.kraken.lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [ 31416 ];
      allowedUDPPorts = [ 31416 ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::1:21";
        };
        address = [
          "10.3.1.21/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  services = {
    boinc = {
      enable = true;
      package = nixpkgs.boinc-headless;
      extraEnvPackages = with nixpkgs; [
        virtualbox
        podman
        libglvnd
        brotli
        ocl-icd
      ];
    };

    alloy-squid = {
      enable = true;
    };
  };

  systemd.tmpfiles.rules = [
    "f /var/lib/boinc/remote_hosts.cfg 0644 boinc boinc - 10.10.0.10"
  ];

  imports =
    let
      profiles = [
        hardwareProfiles.servers
        nixosProfiles.virtualisation
      ];
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
