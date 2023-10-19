{
  inputs,
  cell,
}: let
  inherit (inputs) common nixos-hardware nixpkgs;
in {
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-pc-ssd
    common-cpu-intel-cpu-only
    (nixpkgs + "/nixos/modules/virtualisation/proxmox-lxc.nix")
  ];

  proxmoxLXC = {
    privileged = false;
    manageNetwork = false;
    manageHostName = true;
  };

  inherit (common) hardware;

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    kernelModules = ["kvm-intel"];
    initrd = {
      availableKernelModules = [
        "ahci"
        "ehci_pci"
        "mpt3sas"
        "usbhid"
      ];
    };
    plymouth = {
      enable = true;
      themePackages = [
        ((nixpkgs.catppuccin-plymouth.overrideAttrs
          (finalAttrs: previousAttrs: {
            src = nixpkgs.fetchFromGitHub {
              owner = "gigglesquid";
              repo = "catppuccin-plymouth";
              rev = "ea35464f0f2d865ab9d6db7d07630e95a88c3aac";
              hash = "sha256-zFxsEZ+So14YQjk0TWMAxyIp79MJ/x+bsNSWkadt3+o=";
            };
          }))
        .override {variant = "mocha";})
      ];
      theme = "catppuccin-mocha";
    };
  };
}
