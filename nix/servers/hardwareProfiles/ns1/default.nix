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

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    kernelModules = [ ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
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
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };
  };
}
