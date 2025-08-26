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
      net0 = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=1,tag=3";
      scsihw = "virtio-scsi-single";
      virtio0 = "local-zfs:101/vm-9999-disk-0,aio=io_uring,discard=on,iothread=1";
    };
    qemuExtraConf = {
      cpu = "host";
      numa = 1;
      machine = "q35";
      balloon = 0;
      vmstatestorage = "local-zfs";
    };
    partitionTableType = "efi";
    cloudInit.enable = false;
  };

  virtualisation.diskSize = 16384; # MiB

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
