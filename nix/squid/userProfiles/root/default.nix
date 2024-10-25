{ inputs, config }:
let
  inherit (inputs) self;
in
{
  sops.secrets.user_pass_root = {
    sopsFile = "${self}/sops/squid-rig.yaml";
    neededForUsers = true;
  };
  users = {
    mutableUsers = false;
    users.root = {
      hashedPasswordFile = config.sops.secrets.user_pass_root.path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVJziSSFN+N2kH0EE39oxut9PMWyKJ4Jf0F8axkZe9e"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN6ycNhEFVP15KHUowD7aqlmhryYjTE+BSSbseJsKG1c"
      ];
    };
  };
}
