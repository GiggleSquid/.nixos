{pkgs, ...}: {
  users = {
    users = {
      squid = {
        isNormalUser = true;
        extraGroups = ["wheel" "video" "boinc" "libvirtd" "audio" "input" "power" "nix"];
        uid = 1000;
        shell = pkgs.fish;
      };
    };
  };
  programs.fish.enable = true;
}
