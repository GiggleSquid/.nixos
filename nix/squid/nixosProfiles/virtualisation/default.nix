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
      host = {
        enable = true;
        enableExtensionPack = true;
      };
    };
  };

  users.extraGroups.vboxusers.members = [ "boinc" ];

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
