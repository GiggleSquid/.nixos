{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) common nixpkgs self;
  inherit (cell) hardwareProfiles serverSuites;
  inherit (inputs.cells.squid) nixosSuites homeSuites;
  lib = nixpkgs.lib // builtins;
  hostName = "otel";
in
{
  inherit (common) bee time;
  networking = {
    inherit hostName;
    domain = "lan.gigglesquid.tech";
    firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [ 443 ];
    };
  };

  systemd.network = {
    networks = {
      "10-lan" = {
        matchConfig.Name = "eth0";
        ipv6AcceptRAConfig = {
          Token = "static:::60";
        };
        address = [
          "10.3.0.60/23"
        ];
        gateway = [
          "10.3.0.1"
        ];
      };
    };
  };

  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      ipv6_prefix_env = {
        owner = "caddy";
      };
      bunny_dns_api_key_caddy = {
        owner = "caddy";
      };
      prometheus_web_config = {
        owner = "prometheus";
      };
      prometheus_basic_auth_env_var = {
        owner = "prometheus";
      };
      prometheus_exporters_pve = { };
    };
  };

  systemd.services = {
    caddy.serviceConfig = {
      ExecStartPre = ''${lib.getExe' nixpkgs.coreutils "sleep"} 5'';
      EnvironmentFile = [
        "${config.sops.secrets.ipv6_prefix_env.path}"
        "${config.sops.secrets.bunny_dns_api_key_caddy.path}"
      ];
    };
    grafana.serviceConfig = {
      EnvironmentFile = [
        "${config.sops.secrets.prometheus_basic_auth_env_var.path}"
      ];
    };
  };

  services = {
    caddy = {
      enable = true;
      package = nixpkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/bunny@v1.2.0"
        ];
        hash = "sha256-/m0vN2NwA9IFsowDY/aXebFQdCvFDh5mFcSnuLML6y4=";
      };
      email = "jack.connors@protonmail.com";
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
      logFormat = ''
        output file /var/log/caddy/access.log {
          mode 640
        }
        level INFO
      '';
      globalConfig = # caddyfile
        ''
          metrics
        '';
      extraConfig = # caddyfile
        ''
          (bunny_acme_settings) {
            tls {
              dns bunny {env.BUNNY_API_KEY}
              resolvers 9.9.9.9 149.112.112.112
            }
          }
          (deny_non_local) {
            @denied not remote_ip private_ranges {env.IPV6_PREFIX}
            handle @denied {
              abort
            }
          }
        '';
      virtualHosts = {
        "grafana.otel.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              handle {
                reverse_proxy 127.0.0.1:${toString config.services.grafana.settings.server.http_port}
              }
            '';
        };
        "prometheus.otel.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              handle {
                reverse_proxy 127.0.0.1:${toString config.services.prometheus.port}
              }
            '';
        };
        "loki.otel.lan.gigglesquid.tech" = {
          extraConfig = # caddyfile
            ''
              import bunny_acme_settings
              import deny_non_local
              handle {
                reverse_proxy 127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}
              }
            '';
        };
      };
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3010;
          protocol = "http";
          root_url = "https://grafana.otel.lan.gigglesquid.tech";
        };
        analytics.reporting_enabled = false;
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            uid = "PBFA97CFB590B2093";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            basicAuth = true;
            basicAuthUser = "admin";
            secureJsonData = {
              basicAuthPassword = "$PROMETHEUS_BASIC_AUTH";
            };
          }
          {
            name = "Loki";
            uid = "P8E80F9AEF21F6940";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
          }
        ];
        dashboards.settings.providers = [
          {
            name = "My dashboards";
            options.path = "/etc/grafana-dashboards";
          }
        ];
      };
    };

    prometheus = {
      enable = true;
      port = 3020;
      webExternalUrl = "https://prometheus.otel.lan.gigglesquid.tech";
      webConfigFile = "${config.sops.secrets.prometheus_web_config.path}";
      extraFlags = [
        "--web.enable-remote-write-receiver"
      ];
      exporters = {
        pve = {
          enable = true;
          configFile = "${config.sops.secrets.prometheus_exporters_pve.path}";
        };
      };
      scrapeConfigs = [
        {
          job_name = "pve";
          static_configs = [
            {
              targets = [ "tentacle0.kraken.lan.gigglesquid.tech:8006" ];
            }
          ];
          metrics_path = "/pve";
          params = {
            module = [ "default" ];
            cluster = [ "1" ];
            node = [ "1" ];
          };
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__param_target";
            }
            {
              source_labels = [ "__param_target" ];
              target_label = "instance";
            }
            {
              target_label = "__address__";
              replacement = "127.0.0.1:9221";
            }
          ];
        }
      ];
    };

    loki = {
      enable = true;
      configuration = {
        analytics.reporting_enabled = false;
        server = {
          http_listen_address = "127.0.0.1";
          http_listen_port = 3030;
        };
        auth_enabled = false;

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = {
                store = "inmemory";
              };
              replication_factor = 1;
            };
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
        };

        schema_config = {
          configs = [
            {
              from = "2022-06-06";
              index = {
                prefix = "index_";
                period = "24h";
              };
              object_store = "filesystem";
              schema = "v13";
              store = "tsdb";
            }
          ];
        };

        storage_config = {
          tsdb_shipper = {
            active_index_directory = "/var/lib/loki/boltdb-shipper-active";
            cache_location = "/var/lib/loki/boltdb-shipper-cache";
            cache_ttl = "24h";
          };

          filesystem = {
            directory = "/var/lib/loki/chunks";
          };
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "1w";
        };

        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };

        compactor = {
          working_directory = "/var/lib/loki";
          compactor_ring = {
            kvstore = {
              store = "inmemory";
            };
          };
        };
      };
    };

    alloy-squid = {
      enable = true;
      listenAddr = "10.3.0.60";
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
              {"__path__" = "/var/log/caddy/access.log"},
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
  };

  environment.etc = {
    "grafana-dashboards/proxmox-via-prometheus.json" = {
      source = ./. + "/_grafana-dashboards/10347-proxmox-via-prometheus.json";
      user = "grafana";
      group = "grafana";
    };
    "grafana-dashboards/caddy-monitoring.json" = {
      source = ./. + "/_grafana-dashboards/20802-caddy-monitoring.json";
      user = "grafana";
      group = "grafana";
    };
  };

  imports =
    let
      profiles = [
        hardwareProfiles.servers
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
