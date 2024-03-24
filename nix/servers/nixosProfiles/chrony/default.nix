{
  networking.timeServers = [ ];

  services = {
    chrony = {
      enable = true;
      extraFlags = [ "-x" ];
      extraConfig = ''
        pool uk.pool.ntp.org iburst maxsources 4 minstratum 2 xleave
        pool time.nist.gov maxsources 2 minstratum 2 xleave
        server time.cloudflare.com xleave
        allow 10.0.0.0/8
      '';
    };
    timesyncd.enable = false;
  };
}
