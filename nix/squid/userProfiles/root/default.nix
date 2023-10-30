{
  users.users.root = {
    initialHashedPassword = "$6$m0o.shyjBsMVPpxD$SC3ZLVDNdJRl1p6DetWU0F6kkaSl2mtFx98kTnyTwg.fBJQbqpALByc7F8iQ9d5F8bBgB5o9i77HP/gclSHta/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4CfBSXxCxcfTDDLzKLmoW26wQqjVkHLjIPhpbCoHvV"
    ];
  };
  services.openssh.enable = true;
}
