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
      bootSize = "512M";
      bios = "ovmf";
      cores = 1;
      memory = 1024;
      net0 = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=0,tag=4";
      scsihw = "virtio-scsi-single";
      virtio0 = "cephalonas-vm-storage:vm-9999-disk-1,iothread=1,aio=native";
    };
    qemuExtraConf = {
      cpu = "host";
      numa = 1;
      machine = "q35";
      vmstatestorage = "cephalonas-vm-storage";
    };
    partitionTableType = "efi";
  };

  inherit (common) hardware;

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    kernelModules = [
      "kvm-intel"
      "nf_conntrack"
      "br_netfilter"
      "overlay"
      "iptable_nat"
      "iptable_filter"
      "ip_vs"
      "ip_vs_rr"
      "ip_vs_wrr"
      "ip_vs_sh"
    ];
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
