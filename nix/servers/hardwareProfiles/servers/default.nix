{ inputs }:
let
  inherit (inputs) common nixos-hardware nixpkgs;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-ssd
    common-cpu-intel-cpu-only
    (nixpkgs + "/nixos/modules/virtualisation/proxmox-lxc.nix")
  ];

  proxmoxLXC = {
    privileged = false;
    manageNetwork = false;
    manageHostName = true;
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
