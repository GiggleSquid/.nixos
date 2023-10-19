{
  users.users.root = {
    initialHashedPassword = "$6$2YboufYBM5MYECR8$26f3JBjlrq1cMnFVG7MqudsacLiNboEqVHPOieLxFZtclS7R4Xu9g.WistS/21xK6pj73g1FWGlaHVri6vB/N/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4CfBSXxCxcfTDDLzKLmoW26wQqjVkHLjIPhpbCoHvV"
    ];
  };
  services.openssh.enable = true;
}
