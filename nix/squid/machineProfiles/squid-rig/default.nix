{ inputs, config }:
let
  inherit (inputs) nixpkgs self;
in
{
  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets.borg_repo_pass = { };
  };

  services.borgbackup.jobs = {
    squid-rig_local = {
      paths = [
        "/home"
        "/mnt/steam/"
      ];
      exclude = [
        "*/.cache"
        "*/baloo"
        "*/.dbus"
        "*/.Trash*"
        "*/.local/share/Trash*"
        "*/lost+found"
      ];
      readWritePaths = [ "/mnt/backups/squid-rig_borg" ];
      repo = "/mnt/backups/squid-rig_borg";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "${nixpkgs.coreutils}/bin/cat ${config.sops.secrets.borg_repo_pass.path}";
      };
      compression = "lz4";
      startAt = "0/6:00";
      persistentTimer = true;
      prune.keep = {
        within = "2d";
        daily = 7;
        weekly = 4;
      };
    };
    squid-rig_unimatrix = {
      paths = [
        "/home"
        "/mnt/steam/"
      ];
      exclude = [
        "*/.cache"
        "*/baloo"
        "*/.dbus"
        "*/.Trash*"
        "*/.local/share/Trash*"
        "*/lost+found"
      ];
      # repo = "borg@unimatrix.cephalonas.lan.gigglesquid.tech:.";
      # ipv6 privacy extensions is causing trouble with ssh known hosts. the outgoing address changes so known hosts on unimatrix will always be out of date and shh connections are refused and closed.
      repo = "borg@10.3.1.27:.";
      environment = {
        BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";
      };
      encryption = {
        mode = "repokey-blake2";
        passCommand = "${nixpkgs.coreutils}/bin/cat ${config.sops.secrets.borg_repo_pass.path}";
      };
      compression = "lz4";
      startAt = "0/6:00";
      persistentTimer = true;
      prune.keep = {
        within = "2d";
        daily = 7;
        weekly = 4;
      };
    };
  };
}
