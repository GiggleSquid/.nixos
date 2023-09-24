{pkgs, ...}: {
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [pkgs.OVMFFull.fd];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  systemd.tmpfiles.rules = ["f /dev/shm/looking-glass 0660 squid kvm -"];

  services = {
    spice-vdagentd.enable = true;
  };

  environment.systemPackages = with pkgs; [
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
