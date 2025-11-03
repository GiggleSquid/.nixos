{
  inputs,
  cell,
}:
let
  inherit (inputs) nixos-hardware nixpkgs self;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-ssd
    common-cpu-intel-cpu-only
    common-gpu-amd
  ];

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with nixpkgs; [
        rocmPackages.clr.icd
        rocmPackages.rocm-runtime
      ];
    };
    enableRedistributableFirmware = true;
    printers = {
      ensureDefaultPrinter = "Brother_DCP-L2510D";
      ensurePrinters = [
        {
          name = "Brother_DCP-L2510D";
          location = "Home";
          deviceUri = "usb://Brother/DCP-L2510D%20series?serial=E78299J7N136122";
          model = "drv:///brlaser.drv/brl2520d.ppd";
          ppdOptions = {
            PageSize = "A4";
          };
        }
      ];
    };
  };

  services = {
    printing.drivers = [ nixpkgs.brlaser ];

    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/" ];
    };

  };

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    kernelParams = [
      "video=DP-2:3440:1440@120"
      "video=HDMI-A-1:1920:1080@60"
    ];
    kernelModules = [ "kvm-intel" ];
    kernel.sysctl = {
      # Watch https://github.com/NixOS/nixpkgs/pull/351002
      # will be redundant when merged
      "vm.swappiness" = 150;
      "vm.watermark_boost_scale_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };
    initrd = {
      kernelModules = [ "dm-snapshot" ];
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "ehci_pci"
        "usbhid"
        "sd_mod"
      ];
      luks.devices = {
        "root0".device = "/dev/disk/by-uuid/82272825-b41d-49aa-8b13-120b78ac482d";
        "root1".device = "/dev/disk/by-uuid/fd0d9fe4-d284-409d-8737-3db4b3b12c2d";
        "root2".device = "/dev/disk/by-uuid/1c0f78c2-9071-41a2-a82f-8f61d7b46304";
        "backups".device = "/dev/disk/by-uuid/8c8c3fe4-b5df-4d60-b141-5d5ad6b6a32a";
        "steam0".device = "/dev/disk/by-uuid/f06e951b-3bf5-4011-8266-44d944380803";
        "steam1".device = "/dev/disk/by-uuid/1841fb4d-de0c-4444-83ce-8401fff0311b";
      };
    };

    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = false;
    };

    supportedFilesystems = [
      "btrfs"
      "nfs"
    ];

    binfmt.emulatedSystems = [ "aarch64-linux" ];

    plymouth = {
      enable = true;
      themePackages = [ (nixpkgs.catppuccin-plymouth.override { variant = "mocha"; }) ];
      theme = "catppuccin-mocha";
      logo = "${self}/artwork/SquidNixPlymouth.png";
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/6795-8A54";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

    "/" = {
      device = "/dev/mapper/root0";
      fsType = "btrfs";
      options = [
        "subvol=root"
        "ssd"
        "noatime"
        "commit=30"
        "compress=zstd"
      ];
      noCheck = true;
    };

    "/var/log" = {
      device = "/dev/mapper/root0";
      fsType = "btrfs";
      options = [
        "subvol=log"
        "ssd"
        "noatime"
        "commit=30"
        "compress=zstd"
      ];
      noCheck = true;
      neededForBoot = true;
    };

    "/nix" = {
      device = "/dev/mapper/root0";
      fsType = "btrfs";
      options = [
        "subvol=nix"
        "ssd"
        "noatime"
        "commit=30"
        "compress=zstd"
      ];
      noCheck = true;
    };

    "/home" = {
      device = "/dev/mapper/root0";
      fsType = "btrfs";
      options = [
        "subvol=home"
        "ssd"
        "noatime"
        "commit=30"
        "compress=zstd"
      ];
      noCheck = true;
    };

    "/mnt/backups" = {
      device = "/dev/mapper/backups";
      fsType = "ext4";
    };

    "/mnt/steam" = {
      device = "/dev/volgroup_steam/lv_steam";
      fsType = "ext4";
    };

    "/mnt/cephalonas/media" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media";
      fsType = "nfs";
      noCheck = true;
      options = [
        "x-systemd.automount"
        "x-systemd.idle-timeout=3600"
        "_netdev"
        "nconnect=6"
      ];
    };
  };
}
