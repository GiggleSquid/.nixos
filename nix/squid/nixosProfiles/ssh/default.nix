{
  # programs.ssh.startAgent = true;
  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
    fail2ban = {
      enable = true;
      maxretry = 3;
      ignoreIP = [
        "10.0.0.0/8"
        "185.250.11.100"
        "185.250.11.244/30"
        "2a0b:9401:64::/48"
      ];
      bantime = "6h";
      bantime-increment = {
        enable = true;
        factor = "1";
        maxtime = "168h";
        rndtime = "11m";
      };
    };
  };
}
