{pkgs, ...}: {
  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    nvidia = {
      modesetting.enable = true;
      open = true;
      nvidiaSettings = true;
      powerManagement.enable = true;
      forceFullCompositionPipeline = true;
    };
    opengl.extraPackages = with pkgs; [nvidia-vaapi-driver];
  };
}
