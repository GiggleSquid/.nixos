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
    squid-top_unimatrix = {
      paths = [ "/home" ];
      exclude = [
        "*/.cache"
        "*/baloo"
        "*/.dbus"
        "*/.Trash*"
        "*/.local/share/Trash*"
        "*/lost+found"
      ];
      repo = "borg@unimatrix.cephalonas.lan.gigglesquid.tech:.";
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
