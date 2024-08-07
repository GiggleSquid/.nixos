{ inputs }:
let
  inherit (inputs) common nixos-hardware nixpkgs;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-cpu-intel-cpu-only
    (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
  ];

  inherit (common) hardware;

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 4;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "xhci_pci"
        "ahci"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
      ];
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/2089-7621";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/" = {
      device = "/dev/disk/by-uuid/76aafbf8-182f-445e-bfd0-1099ae09abb8";
      fsType = "ext4";
    };

    "/mnt/borg/repos" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/backups/unimatrix";
      fsType = "nfs";
      noCheck = true;
    };
  };

}
