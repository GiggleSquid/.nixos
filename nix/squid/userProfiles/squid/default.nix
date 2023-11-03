{
  inputs,
  cell,
  # config,
}: let
  inherit (inputs) nixpkgs;
in {
  users.users.squid = {
    initialHashedPassword = "$6$1KocIsrw7AqDtt3/$ON4m5yb/XMH8pUXHW05Ps5rGAlt.H4F.8boIbVj8gUOoA3vRv6f4TZk7DlQWv1VVGVHFK3bOuPA0B74I6R0bJ.";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN6ycNhEFVP15KHUowD7aqlmhryYjTE+BSSbseJsKG1c"
    ];
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    extraGroups = ["wheel" "video" "audio" "input" "power" "libvirtd" "boinc"];
    shell = nixpkgs.fish;
  };
  programs.fish.enable = true;
}
