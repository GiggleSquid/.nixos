{
  inputs,
  cell,
  config,
}: let
  inherit (inputs) nixpkgs;
in {
  users.users.nixos = {
    initialHashedPassword = "$6$1r2jPEFZNED9GXqz$ISSTI3YF1JmjnAmUPJ8djwCT9dFziASyuFGvQ7.nATofAobwo/213B0Ac.ha4rVFkprS695uDBgzHf8pm3Y1k1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4CfBSXxCxcfTDDLzKLmoW26wQqjVkHLjIPhpbCoHvV"
    ];
    isNormalUser = true;
    uid = 1001;
    createHome = true;
    extraGroups = ["wheel" "video" "audio" "input" "power"];
    shell = nixpkgs.fish;
  };
  programs.fish.enable = true;
}
