{ inputs }:
let
  inherit (inputs) common nixos-hardware nixpkgs;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-ssd
    common-cpu-intel-cpu-only
    "${modulesPath}/virtualisation/proxmox-lxc.nix"
  ];

  proxmoxLXC = {
    privileged = false;
    manageNetwork = true;
    manageHostName = true;
  };

  services.chrony.enable = nixpkgs.lib.mkForce false;

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
