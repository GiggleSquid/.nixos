{ inputs }:
let
  inherit (inputs) common nixos-hardware nixpkgs;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-ssd
  ];

  hardware = common.hardware // {
    bluetooth.enable = false;
  };

  console.enable = false;

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    kernelModules = [ "pps-gpio" ];
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 10;
        # uputronics gps hat pumps out noise over uart
        extraInstallCommands = ''
          echo "timeout menu-disabled" >> /boot/loader/loader.conf
        '';
      };
      efi.canTouchEfiVariables = false;
    };
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "vc4"
        "pcie_brcmstb" # required for the pcie bus to work
        "reset-raspberrypi" # required for vl805 firmware to load
      ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/05F6-BAD7";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
  };
}
