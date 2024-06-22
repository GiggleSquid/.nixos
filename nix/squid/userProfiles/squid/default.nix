{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) self nixpkgs;
in
{
  sops.secrets.user_pass_squid = {
    sopsFile = "${self}/sops/squid-rig.yaml";
    neededForUsers = true;
  };
  users = {
    users.squid = {
      hashedPasswordFile = config.sops.secrets.user_pass_squid.path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN6ycNhEFVP15KHUowD7aqlmhryYjTE+BSSbseJsKG1c"
      ];
      isNormalUser = true;
      uid = 1000;
      createHome = true;
      group = "squid";
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "input"
        "power"
        "libvirtd"
        "boinc"
        "users"
        "dialout"
        "scanner"
        "lp"
      ];
      shell = nixpkgs.fish;
    };
    groups.squid = {
      name = "squid";
      gid = 1000;
    };
  };
  programs.fish.enable = true;
}
