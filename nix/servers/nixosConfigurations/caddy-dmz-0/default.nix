{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) rpi nixpkgs self;
  inherit (cell) serverSuites hardwareProfiles nixosProfiles;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "dmz-0";
in
{
  inherit (rpi) bee time;
  networking = {
    inherit hostName;
    domain = "caddy.lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [
        80
        443
        # 25565
        # 25566
      ];
      allowedUDPPorts = [
        443
        # 25566
      ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "end0";
        ipv6AcceptRAConfig = {
          Token = "static:::10";
        };
        address = [
          "10.100.0.10/24"
          "10.100.0.11/24"
          "2a0b:9401:64:100::11/64"
        ];
        gateway = [
          "10.100.0.1"
        ];
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      crowdsec_bouncer_api_keys_env = { };
      "crowdsec_bouncer_api_keys/caddy_dmz-0_firewall" = { };
      "valkey/caddy-dmz/env" = { };
      "valkey/caddy-dmz/pass" = { };
    };
  };

  systemd.services = {
    caddy.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.crowdsec_bouncer_api_keys_env.path}"
        "${config.sops.secrets."valkey/caddy-dmz/env".path}"
      ];
    };
  };

  services = {
    redis = {
      package = nixpkgs.valkey;
      servers = {
        "${hostName}-a" = {
          enable = true;
          port = 6380;
          appendOnly = true;
          requirePassFile = "${config.sops.secrets."valkey/caddy-dmz/pass".path}";
          databases = 1;
          settings = {
            cluster-enabled = true;
            # This option does not exist in the current latest version in nixpkgs.
            # Use `databases` instead
            # cluster-databases = 1;
            cluster-announce-hostname = "valkey-a.${hostName}.caddy.lan.gigglesquid.tech";
            cluster-preferred-endpoint-type = "hostname";
          };
        };
        "${hostName}-b" = {
          enable = true;
          port = 6381;
          appendOnly = true;
          requirePassFile = "${config.sops.secrets."valkey/caddy-dmz/pass".path}";
          databases = 1;
          settings = {
            cluster-enabled = true;
            # cluster-databases = 1;
            cluster-announce-hostname = "valkey-b.${hostName}.caddy.lan.gigglesquid.tech";
            cluster-preferred-endpoint-type = "hostname";
          };
        };
        "${hostName}-c" = {
          port = 6382;
          enable = true;
          appendOnly = true;
          requirePassFile = "${config.sops.secrets."valkey/caddy-dmz/pass".path}";
          databases = 1;
          settings = {
            cluster-enabled = true;
            # cluster-databases = 1;
            cluster-announce-hostname = "valkey-c.${hostName}.caddy.lan.gigglesquid.tech";
            cluster-preferred-endpoint-type = "hostname";
          };
        };
      };
    };

    alloy-squid = {
      enable = true;
      export = {
        caddy = {
          metrics = true;
          logs = true;
        };
      };
    };

    crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_url = "https://crowdsec.lan.gigglesquid.tech:8443";
      };
      secrets = {
        apiKeyPath = "${config.sops.secrets."crowdsec_bouncer_api_keys/caddy_dmz-0_firewall".path}";
      };
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles.rpi4
        nixosProfiles.caddy-dmz
      ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          base-rpi
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
