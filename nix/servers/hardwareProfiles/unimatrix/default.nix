{ inputs }:
let
  inherit (inputs) common nixos-hardware nixpkgs;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-cpu-intel-cpu-only
    (nixpkgs + "/nixos/modules/virtualisation/incus-virtual-machine.nix")
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
    initrd = {
      availableKernelModules = [
        "virtio_blk"
      ];
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      neededForBoot = true;
      autoResize = true;
    };

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
