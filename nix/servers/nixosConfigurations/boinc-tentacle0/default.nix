{ inputs, cell }:
let
  inherit (inputs) common nixpkgs;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
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

  services = {
    boinc = {
      enable = true;
      package = nixpkgs.boinc-headless;
      extraEnvPackages = with nixpkgs; [
        libglvnd
        brotli
        ocl-icd
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "f /var/lib/boinc/remote_hosts.cfg 0644 boinc boinc - 10.10.0.10"
  ];

  imports =
    let
      profiles = [ hardwareProfiles.servers ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
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
