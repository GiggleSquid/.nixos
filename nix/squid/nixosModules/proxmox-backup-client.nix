{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.proxmox-backup-client;
in
{
  options = {
    services.proxmox-backup-client = {
      enable = lib.mkEnableOption "Command line client for Proxmox Backup Server";

      package = lib.mkPackageOption pkgs "proxmox-backup-client" { };

      backup = {
        archives = lib.mkOption {
          default = { };
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    Name of the backup archive.

                    The 'archive-name' must only contain alphanumerics, hyphens, and underscores
                  '';
                  example = "home";
                };
                type = lib.mkOption {
                  type = lib.types.enum [
                    "pxar"
                    "img"
                    "conf"
                    "log"
                  ];
                  description = ''
                    Type of archive (format).

                    Must be either 'pxar', 'img', 'conf', or 'log'.
                  '';
                  example = "img";
                  default = "pxar";
                };
                sourcePath = lib.mkOption {
                  type = lib.types.str;
                  description = "Path to backup";
                  example = "/home";
                };
              };
            }
          );
        };
        type = lib.mkOption {
          type = lib.types.enum [
            "vm"
            "ct"
            "host"
          ];
          description = ''
            Type of backup.

            Must be either 'vm', 'ct', or 'host'.
          '';
          example = "vm";
          default = "host";
        };
        cryptMode = lib.mkOption {
          type = lib.types.enum [
            "none"
            "encrypt"
            "sign-only"
          ];
          description = ''
            Defines whether data is encrypted (using an AEAD cipher).

            Must be encrypt, sign-only, or none.
          '';
          example = "sign-only";
          default = "encrypt";
        };
        keyFile = lib.mkOption {
          type = with lib.types; nullOr path;
          description = ''
            Path to encryption key. All data will be encrypted using this key.
          '';
          example = "/path/to/encryption/keyfile";
          default = null;
        };
        changeDetectionMode = lib.mkOption {
          type = lib.types.enum [
            "legacy"
            "data"
            "metadata"
          ];
          description = ''
            Mode to detect file changes since last backup run.

            Must be either 'legacy', 'data', or 'metadata'.
          '';
          example = "legacy";
          default = "metadata";
        };
        ns = lib.mkOption {
          type = with lib.types; nullOr str;
          description = "Namespace of datastore";
          default = null;
          example = "namespace/name";
        };
        exclude = lib.mkOption {
          type = with lib.types; nullOr (listOf str);
          default = null;
          description = ''
            List of paths or patterns for matching files to exclude.
          '';
          example = [
            "**/.cache"
            "/nix"
          ];
        };
        environmentFile = lib.mkOption {
          type = with lib.types; nullOr path;
          description = ''
            Path to environment file.
          '';
          default = null;
        };
        frequency = lib.mkOption {
          type = lib.types.str;
          description = ''
            Frequency to run systemd unit timer.

            Systemd on calendar time.
          '';
          default = "0/06:00";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services.proxmox-backup-client = {
        description = "Proxmox Backup Client Job";
        after = [ "network.target" ];

        environment.HOME = "%T/proxmox-backup-client";

        serviceConfig = {
          Type = "oneshot";
          Restart = "on-failure";
          RestartSec = "5min";

          AmbientCapabilities = "CAP_DAC_READ_SEARCH";
          CapabilityBoundingSet = "CAP_DAC_READ_SEARCH";

          CPUSchedulingPolicy = "idle";
          IOSchedulingClass = "idle";

          DynamicUser = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = "read-only";
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RestrictAddressFamilies = "AF_INET AF_INET6";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          UMask = "0077";

          EnvironmentFile = cfg.backup.environmentFile;

          ExecStart =
            "${lib.getExe cfg.package} backup "
            + (lib.concatStringsSep " " (
              lib.imap0 (
                i: archives: "${archives.name}.${archives.type}:${archives.sourcePath}"
              ) cfg.backup.archives
            ))
            + " --backup-type=${cfg.backup.type}"
            + " --crypt-mode=${cfg.backup.cryptMode}"
            + " --change-detection-mode=${cfg.backup.changeDetectionMode}"
            + (if cfg.backup.keyFile != null then " --keyfile=${cfg.backup.keyFile}" else "")
            + (if cfg.backup.ns != null then " --ns=${cfg.backup.ns}" else "")
            + (
              if cfg.backup.exclude != null then
                (lib.concatMapStrings (s: " --exclude=" + s) cfg.backup.exclude)
              else
                ""
            );
        };
      };
      timers.proxmox-backup-client = {
        description = "Run proxmox-backup-client";
        wantedBy = [ "timers.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        timerConfig = {
          OnCalendar = cfg.backup.frequency;
          Persistent = true;
          RandomizedDelaySec = "10m";
        };
      };
    };
  };
}
