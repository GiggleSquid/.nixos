{ inputs }:
let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib // builtins;
in
{
  networking = {
    useDHCP = false;
    useHostResolvConf = false;
  };

  services = {
    chrony = {
      enable = true;
      # servers = lib.mkDefault [ "timesquid-0.ntp.lan.gigglesquid.tech" ];
      initstepslew.enabled = lib.mkDefault false;
      extraFlags = [ "-s" ];
      extraConfig = lib.mkDefault ''
        makestep 25 3
        pool uk.pool.ntp.org iburst
      '';
    };
    timesyncd.enable = false;
    resolved.fallbackDns = [ ];
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-lan" = {
        DHCP = lib.mkDefault "no";
        networkConfig = {
          IPv6PrivacyExtensions = lib.mkDefault "no";
        };
        linkConfig.RequiredForOnline = lib.mkDefault "routable";
      };
    };
  };
}
