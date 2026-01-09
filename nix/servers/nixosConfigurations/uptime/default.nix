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
  hostName = "uptime";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [
        443
      ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "enp1s0";
        address = [
          "2a01:4f8:1c1a:25f0::10/64"
          "167.235.72.13/32"
        ];
        routes = [
          { Gateway = "fe80::1"; }
          {
            Gateway = "172.31.1.1";
            GatewayOnLink = true;
          }
        ];
        dns = [
          "2620:fe::fe"
          "2620:fe::9"
          "9.9.9.9"
          "149.112.112.112"
        ];
      };
    };
  };

  zramSwap = {
    memoryPercent = 25;
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      crowdsec_bouncer_api_keys_env = { };
      "crowdsec_bouncer_api_keys/uptime_firewall" = { };
    };
  };

  systemd.services = {
    caddy.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.crowdsec_bouncer_api_keys_env.path}"
      ];
    };
  };

  services = {
    uptime-kuma = {
      enable = true;
      package = pkgs.uptime-kuma;
    };
    caddy-squid = {
      enable = true;
      externalService = true;
      plugins = {
        extra = [
          "github.com/hslatman/caddy-crowdsec-bouncer@v0.9.2"
        ];
        hash = "sha256-upxqOJdnxMG40jme4ZdiQSfxIPklOHriLc6SA8n7ylw=";
      };
      extraGlobalConfig = # caddyfile
        ''
          crowdsec {
            api_url https://crowdsec.gigglesquid.tech:8443
            # appsec_url https://crowdsec.gigglesquid.tech:7422
            api_key {env.CROWDSEC_UPTIME_CADDY_API_KEY}
            ticker_interval 15s
          }
        '';
    };
    caddy.virtualHosts = {
      "uptime.gigglesquid.tech" =
        { name, ... }:
        {
          logFormat = ''
            output file ${config.services.caddy.logDir}/access-${
              lib.replaceStrings [ "/" " " ] [ "_" "_" ] name
            }.log {
              mode 640
            }
            level INFO
            format json
          '';
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              encode zstd gzip
              route {
                reverse_proxy localhost:3001 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
      "status.thatferret.blog" =
        { name, ... }:
        {
          logFormat = ''
            output file ${config.services.caddy.logDir}/access-${
              lib.replaceStrings [ "/" " " ] [ "_" "_" ] name
            }.log {
              mode 640
            }
            level INFO
            format json
          '';
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              encode zstd gzip
              route {
                reverse_proxy localhost:3001 {
                  header_up Host {upstream_hostport}
                }
              }
            '';
        };
    };

    crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_url = "https://crowdsec.gigglesquid.tech:8443";
      };
      secrets = {
        apiKeyPath = "${config.sops.secrets."crowdsec_bouncer_api_keys/uptime_firewall".path}";
      };
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.hetzner ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          base
          caddy-server
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
