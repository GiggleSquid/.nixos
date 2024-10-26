{
  inputs,
  cell,
  config,
}:
let
  inherit (inputs) nixos-hardware nixpkgs;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-ssd
    common-cpu-intel-cpu-only
    common-gpu-amd
  ];

  hardware = {
    graphics.enable = true;
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

  services.printing.drivers = [ nixpkgs.brlaser ];

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    kernelParams = [
      "video=DP-2:3440:1440@120"
      "video=HDMI-A-1:1920:1080@60"
    ];
    kernelModules = [ "kvm-intel" ];
    initrd = {
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
      efi.canTouchEfiVariables = true;
    };

    binfmt.emulatedSystems = [ "aarch64-linux" ];

    plymouth = {
      enable = true;
      themePackages = [ (nixpkgs.catppuccin-plymouth.override { variant = "mocha"; }) ];
      theme = "catppuccin-mocha";
      # logo = "${self}/artwork/SquidNixPlymouth.png";
    };
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

    "/mnt/steam" = {
      device = "/dev/volgroup_steam/lv_steam";
      fsType = "ext4";
    };

    "/mnt/cephalonas/media" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media";
      fsType = "nfs";
      noCheck = true;
    };

    "/mnt/cephalonas/media/torrent-downloads" = {
      device = "cephalonas.lan.gigglesquid.tech:/mnt/main/media/torrent-downloads";
      fsType = "nfs";
      noCheck = true;
    };
  };
}
