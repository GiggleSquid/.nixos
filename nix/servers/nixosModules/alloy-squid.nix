{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) self;
  lib = inputs.nixpkgs.lib;
in
let
  cfg = config.services.alloy-squid;
in
{
  options.services.alloy-squid = {
    enable = lib.mkEnableOption (lib.mdDoc "alloy-squid");

    listenAddr = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 12345;
    };

    export = {
      localMetrics = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      journalLogs = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      caddy = {
        metrics = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        logs = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };
    };

    alloyConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };

    supplementaryGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    services.alloy = {
      enable = true;
      extraFlags = [
        "--disable-reporting"
        "--server.http.listen-addr=${cfg.listenAddr}:${toString cfg.listenPort}"
      ];
    };

    environment.etc."alloy/config.alloy".text =
      # alloy
      ''
        prometheus.remote_write "prometheus_service" {
          endpoint {
            url = "https://prometheus.otel.lan.gigglesquid.tech/api/v1/write"
            basic_auth {
              username = "admin"
              password_file = "${config.sops.secrets.prometheus_basic_auth.path}"
            }
          }
        }

        loki.write "loki_service" {
          endpoint {
            url = "https://loki.otel.lan.gigglesquid.tech/loki/api/v1/push"
            //basic_auth {
            //  username = "admin"
            //  password_file = ""
            //}
          }
        }
      ''
      + (lib.optionalString cfg.export.localMetrics
        # alloy
        ''
          prometheus.exporter.unix "local_system" {
            enable_collectors = ["systemd"]
            systemd {
              start_time = true
              unit_exclude = ".+\\.(automount|device|scope|slice)"
            }
          }

          prometheus.scrape "scrape_metrics" {
            targets         = prometheus.exporter.unix.local_system.targets
            forward_to      = [prometheus.remote_write.prometheus_service.receiver]
            scrape_interval = "15s"
          }
        ''
      )
      + (lib.optionalString cfg.export.journalLogs
        # alloy
        ''
          loki.source.journal "journal" {
            forward_to = [loki.write.loki_service.receiver]
            relabel_rules = loki.relabel.journal.rules
          }

          loki.relabel "journal" {
            forward_to = []

            rule {
              source_labels = ["__journal__systemd_unit"]
              target_label  = "systemd_unit"
            }
            rule {
              source_labels = ["__journal__hostname"]
              target_label  = "hostname"
              replacement   = "${config.networking.fqdn}"
            }
          }
        ''
      )
      + (lib.optionalString cfg.export.caddy.metrics
        # alloy
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
            forward_to      = [prometheus.remote_write.prometheus_service.receiver]
            scrape_interval = "15s"
            job_name   = "caddy.metrics.scrape"
          }
        ''
      )
      + (lib.optionalString cfg.export.caddy.logs
        # alloy
        ''
          local.file_match "caddy_access_log" {
            path_targets = [
              {"__path__" = "/var/log/caddy/*.log"},
            ]
            sync_period = "15s"
          }

          loki.source.file "caddy_access_log" {
            targets    = local.file_match.caddy_access_log.targets
            forward_to = [loki.process.caddy_process_logs.receiver]
            tail_from_end = true
          }

          loki.process "caddy_process_logs" {
            stage.json {
              expressions = {
                ts = "",
              }
            }

            stage.timestamp {
              source = "ts"
              format = "unix"
            }

            stage.static_labels {
              values = {
                job = "loki.source.file.caddy_access_log",
                host   = "${config.networking.fqdn}",
              }
            }
            
            forward_to = [loki.write.loki_service.receiver]
          }
        ''
      )
      + cfg.alloyConfig;

    systemd.services.alloy.serviceConfig = {
      SupplementaryGroups = [
        "alloy"
      ]
      ++ (lib.lists.optionals (cfg.export.caddy.logs) [
        "caddy"
      ])
      ++ cfg.supplementaryGroups;
    };

    sops = {
      defaultSopsFile = "${self}/sops/squid-rig.yaml";
      secrets = {
        prometheus_basic_auth = {
          mode = "0440";
          owner = "alloy";
        };
      };
    };

    users = {
      users.alloy = {
        group = "alloy";
        isSystemUser = true;
      };
      groups.alloy = { };
    };
  };
}
