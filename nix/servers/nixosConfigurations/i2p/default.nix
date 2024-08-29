{ inputs, cell }:
let
  inherit (inputs) common nixpkgs;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  inherit (inputs.cells.toolchain) pkgs;
  lib = nixpkgs.lib // builtins;
  hostName = "i2p";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [
        19169
        7070
        4444
        7656
      ];
      allowedUDPPorts = [
        19169
        7070
        4444
        7656
      ];
    };
  };

  services = {
    i2pd = {
      package = pkgs.i2pd;
      enable = true;
      logLevel = "info";
      bandwidth = 5000;
      port = 19169;
      addressbook.subscriptions = [
        "http://inr.i2p/export/alive-hosts.txt"
        "http://i2p-projekt.i2p/hosts.txt"
        "http://stats.i2p/cgi-bin/newhosts.txt"
        "http://reg.i2p/hosts.txt"
      ];
      proto = {
        http = {
          enable = true;
          address = "10.3.0.40";
          port = 7070;
          hostname = "i2p.lan.gigglesquid.tech";
          auth = true;
          user = "squid";
        };
        httpProxy = {
          enable = true;
          address = "10.3.0.40";
          port = 4444;
        };
        sam = {
          enable = true;
          address = "10.3.0.40";
          port = 7656;
        };
      };
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.servers ];
      suites = with serverSuites; lib.concatLists [ nixosSuites.server ];
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
