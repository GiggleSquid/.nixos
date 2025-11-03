{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) rpi nixpkgs self;
  inherit (cell) serverSuites hardwareProfiles;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "dmz";
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
    };
  };

  systemd.services = {
    caddy.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.crowdsec_bouncer_api_keys_env.path}"
      ];
    };
    crowdsec-firewall-bouncer.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.crowdsec_bouncer_api_keys_env.path}"
      ];
    };
  };

  services = {
    caddy-squid = {
      enable = true;
      plugins = {
        extra = [
          "github.com/hslatman/caddy-crowdsec-bouncer@v0.9.2"
          "github.com/mholt/caddy-l4@v0.0.0-20251001194302-2e3e6cf60b25"
        ];
        hash = "sha256-uC4QfSSW221WdvMlflOSPMX7vUEcOppFGrnU9QbflnU=";
      };
      extraGlobalConfig = # caddyfile
        ''
          crowdsec {
            api_url https://crowdsec.lan.gigglesquid.tech:8443
            # appsec_url https://crowdsec.lan.gigglesquid.tech:7422
            api_key {env.CROWDSEC_CADDY_DMZ_CADDY_API_KEY}
            ticker_interval 15s
          }
        '';
    };
    caddy.virtualHosts = {
      "squidjelly.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            log
            import bunny_acme_settings
            route {
              crowdsec
              reverse_proxy https://squidjelly.internal.caddy.lan.gigglesquid.tech {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
      "squidseerr.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            log
            import bunny_acme_settings
            route {
              crowdsec
              reverse_proxy https://squidseerr.internal.caddy.lan.gigglesquid.tech {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
      "squidcasts.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            log
            import bunny_acme_settings
            route {
              crowdsec
              reverse_proxy https://squidcasts.internal.caddy.lan.gigglesquid.tech {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
      "old.cfwrs.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            log
            import bunny_acme_settings
            route {
              crowdsec
              reverse_proxy https://old.cfwrs.org.uk.internal.caddy.lan.gigglesquid.tech {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
      "cfwrs.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            log
            import bunny_acme_settings
            route {
              crowdsec
              reverse_proxy https://cfwrs.org.uk.internal.caddy.lan.gigglesquid.tech {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
      "origin.thatferret.blog" = {
        extraConfig = # caddyfile
          ''
            log
            import bunny_acme_settings
            route {
              crowdsec
              reverse_proxy https://thatferret.blog.internal.caddy.lan.gigglesquid.tech {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
      "thatferret.blog" = {
        extraConfig = # caddyfile
          ''
            log
            import bunny_acme_settings
            route {
              crowdsec
              reverse_proxy https://thatferret.blog.internal.caddy.lan.gigglesquid.tech {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
      "thatferret.shop" = {
        extraConfig = # caddyfile
          ''
            log
            import bunny_acme_settings
            route {
              crowdsec
              reverse_proxy https://thatferret.shop.internal.caddy.lan.gigglesquid.tech {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
      "gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            log
            import bunny_acme_settings
            route {
              crowdsec
              reverse_proxy https://gigglesquid.tech.internal.caddy.lan.gigglesquid.tech {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
      "umami.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            log
            import bunny_acme_settings
            route {
              crowdsec
              reverse_proxy https://umami.internal.caddy.lan.gigglesquid.tech {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
      "idm.gigglesquid.tech" = {
        extraConfig = # caddyfile
          ''
            log
            import bunny_acme_settings
            route {
              crowdsec
              reverse_proxy https://idm.internal.caddy.lan.gigglesquid.tech {
                header_up Host {upstream_hostport}
              }
            }
          '';
      };
    };

    alloy-squid = {
      enable = true;
      supplementaryGroups = [ "caddy" ];
      alloyConfig = # river
        ''
          discovery.relabel "caddy" {
            targets = [{
              __address__ = "localhost:2019",
            }]
            rule {
              target_label = "instance"
              replacement  = constants.hostname
            }
          }

          prometheus.scrape "caddy" {
            targets         = discovery.relabel.caddy.output
            forward_to      = [prometheus.remote_write.metrics_service.receiver]
            scrape_interval = "15s"
            job_name   = "caddy.metrics.scrape"
          }

          local.file_match "caddy_access_log" {
            path_targets = [
              {"__path__" = "/var/log/caddy/access-global.log"},
            ]
            sync_period = "15s"
          }

          loki.source.file "caddy_access_log" {
            targets    = local.file_match.caddy_access_log.targets
            forward_to = [loki.process.caddy_add_labels.receiver]
            tail_from_end = true
          }

          loki.process "caddy_add_labels" {
            stage.json {
              expressions = {
                level = "",
                logger = "",
                host = "request.host",
                method = "request.method",
                proto = "request.proto",
                ts = "",
              }
            }

            stage.labels {
              values = {
                level = "",
                logger = "",
                host = "",
                method = "",
                proto = "",
              }
            }

            stage.static_labels {
              values = {
                job = "loki.source.file.caddy_access_log",
              }
            }

            stage.timestamp {
              source = "ts"
              format = "unix"
            }
           
            forward_to = [loki.write.grafana_loki.receiver]
          }
        '';
    };

    crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_key = ''''${CROWDSEC_CADDY_DMZ_FIREWALL_API_KEY}'';
        api_url = "https://crowdsec.lan.gigglesquid.tech:8443";
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  imports =
    let
      profiles = [ hardwareProfiles.rpi4 ];
      suites =
        with serverSuites;
        lib.concatLists [
          nixosSuites.server
          base-rpi
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
