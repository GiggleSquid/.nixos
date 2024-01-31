{
  inputs,
  cell,
  config,
}: let
  inherit (inputs) self nixpkgs;
in {
  sops.secrets.user_pass_nixos = {
    sopsFile = "${self}/sops/squid-rig.yaml";
    neededForUsers = true;
  };
  users = {
    users.nixos = {
      hashedPasswordFile = config.sops.secrets.user_pass_nixos.path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN6ycNhEFVP15KHUowD7aqlmhryYjTE+BSSbseJsKG1c"
      ];
      isNormalUser = true;
      uid = 1001;
      createHome = true;
      group = "nixos";
      extraGroups = ["wheel" "video" "audio" "input" "power"];
      shell = nixpkgs.fish;
    };
    groups.nixos = {
      name = "nixos";
      gid = 1001;
    };
  };
  programs.fish.enable = true;
}
