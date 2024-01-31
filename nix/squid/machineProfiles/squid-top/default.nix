{
  inputs,
  config,
}: let
  inherit (inputs) nixpkgs self;
in {
  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets.borg_repo_pass = {};
  };
  services.borgmatic = {
    enable = true;
    settings = {
      encryption_passcommand = "${nixpkgs.coreutils}/bin/cat ${config.sops.secrets.borg_repo_pass.path}";
      source_directories = [
        "/home"
      ];
      exclude_patterns = [
        "*/.cache"
      ];
      exclude_caches = true;
      keep_within = "24H";
      keep_daily = 5;
      repositories = [
        {
          label = "cephalonas";
          path = "/mnt/cephalonas/backups/squid-top/squid-top_borg";
        }
      ];
    };
  };
  systemd = {
    timers.borgmatic = {
      enable = true;
      wantedBy = ["timers.target"];
      timerConfig = {
        Unit = "borgmatic.service";
        OnCalendar = "0/3:00";
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
    };
    services.borgmatic = {
      serviceConfig = {
        ProtectSystem = "strict";
        ReadWritePaths = "-/mnt/cephalonas/backups/squid-top/squid-top_borg";
        ReadOnlyPaths = "-/home";
        ProtectHome = "tmpfs";
        BindPaths = "-/root/.cache/borg -/root/.config/borg -/root/.borgmatic";
      };
    };
  };
}
