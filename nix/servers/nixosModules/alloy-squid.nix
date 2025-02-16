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

    exportLocalMetrics = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    exportJournalLogs = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    alloyConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
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
      (lib.optionalString cfg.exportLocalMetrics
        # river
        ''
          prometheus.exporter.unix "local_system" { }

          prometheus.scrape "scrape_metrics" {
            targets         = prometheus.exporter.unix.local_system.targets
            forward_to      = [prometheus.remote_write.metrics_service.receiver]
            scrape_interval = "15s"
          }

          prometheus.remote_write "metrics_service" {
            endpoint {
              url = "https://prometheus.otel.lan.gigglesquid.tech/api/v1/write"
              basic_auth {
                username = "admin"
                password_file = "${config.sops.secrets.prometheus_basic_auth.path}"
              }
            }
          }
        ''
      )
      + (lib.optionalString cfg.exportJournalLogs
        # river
        ''
          loki.source.journal "journal" {
            forward_to = [loki.write.grafana_loki.receiver]
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
            }
          }

          loki.write "grafana_loki" {
            endpoint {
              url = "https://loki.otel.lan.gigglesquid.tech/loki/api/v1/push"
              //basic_auth {
              //  username = "admin"
              //  password_file = ""
              //}
            }
          }
        ''
      )
      + cfg.alloyConfig;

    systemd.services.alloy.serviceConfig = {
      SupplementaryGroups = [
        "alloy"
        "caddy"
      ];
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
