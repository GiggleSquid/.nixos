{
  config,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = ["intel_iommu=on" "iommu=pt" "vfio-pci.ids=10de:1401,10de:0fba" "nvidia.NVreg_PreserveVideoMemoryAllocations=1"];

    plymouth = {
      enable = true;
      themePackages = [(pkgs.catppuccin-plymouth.override {variant = "mocha";})];
      theme = "catppuccin-mocha";
    };

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
        "nvidia"
        "nvidia_modeset"
        "nvidia_uvm"
        "nvidia_drm"
      ];
      secrets = {
        "/crypto_keyfile.bin" = null;
      };
      #Swap device
      luks.devices."luks-ac82ec86-ffc3-4ee8-9d57-3b0e5741e018".device = "/dev/disk/by-uuid/ac82ec86-ffc3-4ee8-9d57-3b0e5741e018";
      luks.devices."luks-ac82ec86-ffc3-4ee8-9d57-3b0e5741e018".keyFile = "/crypto_keyfile.bin";
    };

    # Additional module packages
    extraModulePackages = [config.boot.kernelPackages.nvidia_x11];

    # KVM ignore to prevent windows BSODs
    extraModprobeConfig = ''
      options kvm ignore_msrs=Y report_ignored_msrs=N
    '';
  };
}
