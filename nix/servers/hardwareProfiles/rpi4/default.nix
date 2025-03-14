{ inputs }:
let
  inherit (inputs) nixos-hardware nixpkgs;
  lib = nixpkgs.lib;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-ssd
    raspberry-pi-4
  ];

  hardware = {
    bluetooth.enable = false;
    deviceTree = {
      enable = true;
    };
  };

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    # zfs-kernel support lags behind latest kernels. It's an rpi, when would we want zfs tooling?
    supportedFilesystems.zfs = lib.mkForce false;
  };
}
