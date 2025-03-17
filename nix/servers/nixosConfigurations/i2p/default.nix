{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) common nixpkgs self;
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
      enable = true;
      allowedTCPPorts = [
        19168
        7070
        4444
        7656
      ];
      allowedUDPPorts = [
        19169
        7656
      ];
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      crowdsec_i2p_firewall_api_key_env = { };
    };
  };

  systemd.services = {
    crowdsec-firewall-bouncer.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.crowdsec_i2p_firewall_api_key_env.path}"
      ];
    };
  };

  systemd.services.i2pd.serviceConfig.LimitNOFILE = 8192;

  services = {
    i2pd = {
      package = pkgs.i2pd.override { upnpSupport = false; };
      enable = true;
      logLevel = "error";
      bandwidth = 8192;
      port = 19169;
      limits.transittunnels = 10000;
      floodfill = true;
      ntcp = true;
      ntcp2 = {
        enable = true;
        port = 19168;
        published = true;
      };
      ssu2 = {
        enable = true;
        port = 0;
        published = true;
      };
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

    alloy-squid = {
      enable = true;
      listenAddr = "10.3.0.40";
    };

    crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_key = ''''${CROWDSEC_I2P_FIREWALL_API_KEY}'';
        api_url = "https://crowdsec.lan.gigglesquid.tech:8443";
      };
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.servers ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          i2pd
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
