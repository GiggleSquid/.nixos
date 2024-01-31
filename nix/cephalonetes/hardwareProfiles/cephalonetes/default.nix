{inputs}: let
  inherit (inputs) common nixos-hardware nixpkgs;
in {
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
      scsihw = "virtio-scsi-single";
      virtio0 = "local-zfs:vm-9999-disk-0,iothread=1,aio=native";
      cores = 1;
      memory = 1024;
      bios = "ovmf";
      net0 = "virtio=00:00:00:00:00:00,bridge=vmbr0,firewall=0,tag=4";
    };
    qemuExtraConf = {
      cpu = "host";
      numa = 1;
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
