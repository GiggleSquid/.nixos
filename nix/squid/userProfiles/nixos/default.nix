{
  inputs,
  cell,
  config,
}: let
  inherit (inputs) nixpkgs;
in {
  users.users.nixos = {
    initialHashedPassword = "$6$oafeSIyZjUItxBDW$qptZYMVAMC.3Y8kVtIzoEO5M2bGQhDa7onuBOobvTjN4YbsMGhUCulRxdTKTV3pjdpbY9L6mFbGTLQ3kiwz2k0";
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
