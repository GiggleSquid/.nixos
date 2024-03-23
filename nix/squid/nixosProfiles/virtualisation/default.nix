{inputs}: let
  inherit (inputs) nixpkgs;
in {
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [nixpkgs.OVMFFull.fd];
      };
    };
    spiceUSBRedirection.enable = true;
    docker.enable = true;
  };

  systemd.tmpfiles.rules = ["f /dev/shm/looking-glass 0660 squid kvm -"];

  services = {
    spice-vdagentd.enable = true;
  };

  boot = {
    kernelParams = ["intel_iommu=on" "iommu=pt" "vfio-pci.ids=10de:1401,10de:0fba"];
    extraModprobeConfig = ''
      options kvm ignore_msrs=Y report_ignored_msrs=N
    '';
    initrd = {
      kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];
    };
  };

  environment.systemPackages = with nixpkgs; [
    gnome.adwaita-icon-theme
    looking-glass-client
    spice
    spice-gtk
    spice-protocol
    virt-manager
    virt-viewer
    win-spice
    win-virtio
  ];
}
