{ inputs, cell }:
let
  inherit (inputs)
    commonNvidia
    nixos-hardware
    nixpkgs
    self
    ;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-ssd
    common-cpu-intel-cpu-only
    common-gpu-nvidia-nonprime
  ];

  inherit (commonNvidia) hardware;

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    extraModulePackages = [ nixpkgs.linuxPackages_latest.nvidia_x11 ];
    kernelModules = [ "kvm-intel" ];
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "ehci_pci"
        "usbhid"
        "sd_mod"
      ];
      luks.devices = {
        "root".device = "/dev/disk/by-uuid/21c64da5-832e-4175-a725-aac396633a7d";
        "backups".device = "/dev/disk/by-uuid/8c8c3fe4-b5df-4d60-b141-5d5ad6b6a32a";
      };
    };

    plymouth = {
      enable = true;
      themePackages = [ (nixpkgs.catppuccin-plymouth.override { variant = "mocha"; }) ];
      theme = "catppuccin-mocha";
      logo = "${self}/artwork/SquidNix.png";
    };

    swraid.enable = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/root";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/DCD3-2C5B";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

    "/mnt/backups" = {
      device = "/dev/mapper/backups";
      fsType = "ext4";
    };

    # "/mnt/steam" = {
    #   device = "/dev/disk/by-uuid/e60c1aa4-1c16-49cd-b349-eb433f368145";
    #   fsType = "ext4";
    # };

    "/mnt/cephalonas/backups/squid-rig" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/backups/squid-rig";
      fsType = "nfs";
      noCheck = true;
    };

    "/mnt/cephalonas/media" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media";
      fsType = "nfs";
      noCheck = true;
    };

    "/mnt/cephalonas/media/torrents" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media/torrents";
      fsType = "nfs";
      noCheck = true;
      depends = [ "/mnt/cephalonas/media" ];
    };

    "/mnt/cephalonas/media/torrents/downloads" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media/torrents/downloads";
      fsType = "nfs";
      noCheck = true;
      depends = [ "/mnt/cephalonas/media" ];
    };

    "/mnt/cephalonas/media/squidjelly" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media/squidjelly";
      fsType = "nfs";
      noCheck = true;
      depends = [ "/mnt/cephalonas/media" ];
    };

    "/mnt/cephalonas/media/audiobookshelf" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media/audiobookshelf";
      fsType = "nfs";
      noCheck = true;
      depends = [ "/mnt/cephalonas/media" ];
    };
  };
}
