{
  inputs,
  cell,
  # config,
}: let
  inherit (inputs) nixpkgs;
in {
  users.users.squid = {
    initialHashedPassword = "$6$B8KFagrxZxZU7J77$knmMEQtoPIJNairthrUkALr.y2RWJEoOnLlHbsrpdSgpuscup1B3GsDcnYYVMvyH7tkoS0K0rtvKGRO/vR9Gt/";
    isNormalUser = true;
    uid = 1000;
    createHome = true;
    extraGroups = ["wheel" "video" "audio" "input" "power" "libvirtd" "boinc"];
    shell = nixpkgs.fish;
  };
  programs.fish.enable = true;
}
