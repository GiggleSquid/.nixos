{
  inputs,
  cell,
}: let
  inherit (inputs) commonNvidia nixos-hardware nixpkgs;
in {
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-ssd
    common-cpu-intel-cpu-only
    common-gpu-nvidia-nonprime
  ];

  inherit (commonNvidia) hardware;

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    extraModulePackages = [nixpkgs.linuxPackages_latest.nvidia_x11];
    kernelModules = ["kvm-intel"];
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 4;
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
        "luks-main".device = "/dev/disk/by-uuid/b1c59a07-745f-4618-b502-b2c6cb95b63a";
        "luks-backups".device = "/dev/disk/by-uuid/8c8c3fe4-b5df-4d60-b141-5d5ad6b6a32a";
      };
    };

    plymouth = {
      enable = true;
      themePackages = [
        ((nixpkgs.catppuccin-plymouth.overrideAttrs
          (finalAttrs: previousAttrs: {
            src = nixpkgs.fetchFromGitHub {
              owner = "gigglesquid";
              repo = "catppuccin-plymouth";
              rev = "ea35464f0f2d865ab9d6db7d07630e95a88c3aac";
              hash = "sha256-zFxsEZ+So14YQjk0TWMAxyIp79MJ/x+bsNSWkadt3+o=";
            };
          }))
        .override {variant = "mocha";})
      ];
      theme = "catppuccin-mocha";
    };

    swraid.enable = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/aac57c6e-3471-4214-8e80-4bf9062c67b2";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/7FA7-F6B5";
      fsType = "vfat";
    };

    "/mnt/backups" = {
      device = "/dev/disk/by-uuid/95a47dae-280d-4fd1-a6ff-309db8ed338b";
      fsType = "ext4";
    };

    "/mnt/steam" = {
      device = "/dev/disk/by-uuid/e60c1aa4-1c16-49cd-b349-eb433f368145";
      fsType = "ext4";
    };

    "/mnt/cephalonas/backups/squid-rig" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/Main/Backups/Squid-Rig";
      fsType = "nfs";
      noCheck = true;
    };

    "/mnt/cephalonas/media" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/Main/Media";
      fsType = "nfs";
      noCheck = true;
    };

    "/mnt/cephalonas/torrents" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/Torrents/qbittorrent";
      fsType = "nfs";
      noCheck = true;
    };
  };
}
