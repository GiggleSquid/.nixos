{pkgs, ...}: {
  imports = [./fonts.nix ./services.nix ./pipewire.nix];

  environment.etc."greetd/environments".text = ''
    Hyprland
  '';

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [vaapiVdpau libvdpau-va-gl];
    };
    pulseaudio.support32Bit = true;
  };

  xdg = {
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };
}
