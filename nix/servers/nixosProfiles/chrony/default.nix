{ inputs }:
let
  lib = inputs.nixpkgs.lib;
in
{
  networking.timeServers = lib.mkDefault [ ];

  services = {
    chrony = {
      enable = true;
      servers = [ ];
      initstepslew = {
        enabled = false;
      };
      extraConfig = ''
        pool uk.pool.ntp.org iburst maxsources 4 xleave
        allow 10.0.0.0/8
        initstepslew 30 0.uk.pool.ntp.org 1.uk.pool.ntp.org
        refclock SHM 0 poll 8 precision 1e-1 offset 0.040 delay 0.2 noselect refid GNSS
        refclock PPS /dev/pps0 lock GNSS poll 4 precision 1e-7 prefer
      '';
    };
    timesyncd.enable = false;
  };
}
