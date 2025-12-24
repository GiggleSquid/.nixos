{ inputs }:
let
  inherit (inputs) common nixos-hardware nixpkgs;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-cpu-intel-cpu-only
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
  ];

  inherit (common) hardware;

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 4;
      };
    };
  };

  fileSystems = {
    "/mnt/borg/repos" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/backups/unimatrix";
      fsType = "nfs";
      noCheck = true;
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
  };

}
