{
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    virtualbox = {
      host = {
        enable = true;
        enableExtensionPack = true;
        enableHardening = false;
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
