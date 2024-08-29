{ inputs }:
let
  inherit (inputs) common nixos-hardware nixpkgs;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-ssd
    common-cpu-intel-cpu-only
    (nixpkgs + "/nixos/modules/virtualisation/proxmox-image.nix")
  ];

  proxmox = {
    qemuConf = {
      boot = "order=virtio0";
      bios = "ovmf";
      cores = 1;
      memory = 1024;
      net0 = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=0,tag=4";
      scsihw = "virtio-scsi-single";
      virtio0 = "local-btrfs:9002/base-9002-disk-1.raw,aio=native,iothread=1";
    };
    qemuExtraConf = {
      cpu = "host";
      numa = 1;
      machine = "q35";
      vmstatestorage = "local-btrfs";
    };
    partitionTableType = "efi";
    cloudInit.enable = false; # https://github.com/NixOS/nixpkgs/pull/307287/commits/fe35866a2e23e737ce9ae253bbb5c148ccf10778
  };

  inherit (common) hardware;

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    initrd = {
      availableKernelModules = [
        "ahci"
        "ehci_pci"
        "mpt3sas"
        "usbhid"
      ];
    };
  };
}
