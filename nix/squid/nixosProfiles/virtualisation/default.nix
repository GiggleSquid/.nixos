{
  virtualisation = {
    # libvirtd = {
    #   enable = true;
    #   qemu = {
    #     swtpm.enable = true;
    #     ovmf.enable = true;
    #     ovmf.packages = [ nixpkgs.OVMFFull.fd ];
    #   };
    # };
    # docker.enable = true;
    virtualbox = {
      host.enable = true;
    };
  };

  boot = {
    kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
    ];
    initrd = {
      kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];
    };
  };
}
