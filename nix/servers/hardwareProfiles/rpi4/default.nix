{ inputs }:
let
  inherit (inputs) common nixos-hardware nixpkgs;
  lib = nixpkgs.lib;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-ssd
    raspberry-pi-4
  ];

  hardware = common.hardware // {
    bluetooth.enable = false;
    raspberry-pi."4" = {
      i2c1.enable = true;
    };
    deviceTree = {
      enable = true;
      overlays = [
        {
          name = "ds3231";
          dtsText = ''
            /dts-v1/;
            /plugin/;

            / {
              compatible = "brcm,bcm2711";

              fragment@0 {
                target = <&i2c1>;

                __overlay__ {
                  #address-cells = <1>;
                  #size-cells = <0>;

                  status = "okay";

                  ds3231@68 {
                    compatible = "maxim,ds3231";
                    reg = <0x68>;
                  };
                };
              };
            };'';
        }
      ];
    };
  };

  environment.defaultPackages = [ ];
  documentation.info.enable = false;
  console.enable = false;

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    # The RTC (DS3231) board I have doesn't seem
    # to support the required ioctl interrupts
    kernelPatches = [
      {
        name = "RTC_UIE_EMULATION";
        patch = null;
        structuredExtraConfig.RTC_INTF_DEV_UIE_EMUL = lib.kernel.yes;
      }
    ];
    kernelModules = [
      "i2c-dev"
      "rtc-ds1307"
    ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "usbhid"
        "usb-storage"
        "vc4"
        "pcie-brcmstb"
        "reset-raspberrypi"
      ];
    };
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      # efi.canTouchEfiVariables = false;
    };
    # It's an rpi, do we want zfs tooling?
    supportedFilesystems.zfs = lib.mkForce false;
    swraid.enable = false;
    enableContainers = false;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [
        "noatime"
      ];
    };

    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "nofail"
        "noauto"
      ];
    };
  };
}
