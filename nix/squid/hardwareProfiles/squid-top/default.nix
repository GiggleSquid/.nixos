{ inputs, cell }:
let
  inherit (inputs) common nixos-hardware nixpkgs;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-ssd
    common-pc-laptop
    common-pc-laptop-acpi_call
    common-cpu-intel
    common-cpu-intel-kaby-lake
  ];

  inherit (common) hardware;

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "auto";
        configurationLimit = 4;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      kernelModules = [ ];
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      luks.devices = {
        "luks-main".device = "/dev/disk/by-uuid/341e401a-5a81-454c-bc61-28f3c9a5b77a";
      };
    };

    plymouth = {
      enable = true;
      themePackages = [
        (
          (nixpkgs.catppuccin-plymouth.overrideAttrs (
            finalAttrs: previousAttrs: {
              src = nixpkgs.fetchFromGitHub {
                owner = "gigglesquid";
                repo = "catppuccin-plymouth";
                rev = "ea35464f0f2d865ab9d6db7d07630e95a88c3aac";
                hash = "sha256-zFxsEZ+So14YQjk0TWMAxyIp79MJ/x+bsNSWkadt3+o=";
              };
            }
          )).override
          { variant = "mocha"; }
        )
      ];
      theme = "catppuccin-mocha";
    };

    swraid.enable = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/01d1d7e7-b9d2-43f5-8eea-c95afa0c19d0";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0D5E-EB90";
      fsType = "vfat";
    };

    "/mnt/cephalonas/backups/squid-top" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/Main/Backups/squid-top";
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
