{ inputs, config }:
let
  inherit (inputs) nixpkgs self;
  lib = nixpkgs.lib;
in
{
  sops = {
    defaultSopsFile = "${self}/sops/squid-rig.yaml";
    secrets = {
      "attic/jwt-push-only" = { };
    };
  };

  systemd.services.attic-nix-cache-upload = {
    environment.XDG_CONFIG_HOME = "/var/lib/attic-nix-cache-upload";
    script = ''
      ATTIC_TOKEN=$(< $CREDENTIALS_DIRECTORY/jwt-push-only)
      ${lib.getExe nixpkgs.attic-client} login local-nix-cache https://local.nix-cache.lan.gigglesquid.tech $ATTIC_TOKEN
      ${lib.getExe nixpkgs.attic-client} push attic /run/current-system
      ${lib.getExe nixpkgs.attic-client} watch-store attic
    '';
    wantedBy = [ "multi-user.target" ];
    wants = [ "network.target" ];
    after = [ "network.target" ];
    startLimitIntervalSec = 5;
    startLimitBurst = 5;
    serviceConfig = {
      Type = "exec";
      Restart = "on-failure";

      ExecStartPre = ''${lib.getExe' nixpkgs.coreutils "sleep"} 10'';

      LoadCredential = "jwt-push-only:${config.sops.secrets."attic/jwt-push-only".path}";

      StateDirectory = "attic-nix-cache-upload";

      PrivateDevices = true;
      PrivateUsers = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectKernelLogs = true;
      ProtectClock = true;
      ProtectProc = "invisible";
    };
  };
}
