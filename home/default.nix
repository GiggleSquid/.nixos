{inputs, ...}: {
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
  home.sessionVariables = {
    EDITOR = "hx";
    BROWSER = "librewolf";
    NIXOS_OZONE_WL = 1;
    WLR_NO_HARDWARE_CURSORS = 1;
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    MOZ_ENABLE_WAYLAND = 1;
    WLR_BACKEND = "vulkan";
    WLR_RENDERER = "vulkan";
    SDL_VIDEODRIVER = "wayland";
  };

  imports = [
    inputs.anyrun.homeManagerModules.default
    ./pkgs.nix
    ./cli
    ./misc
    ./rice
  ];
}
