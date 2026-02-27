{ inputs }:
let
  inherit (inputs) common nixos-hardware nixpkgs;
in
{
  imports = with nixos-hardware.nixosModules; [
    common-pc
    common-cpu-intel-cpu-only
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  inherit (common) hardware;

  boot = {
    kernelPackages = nixpkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 4;
      };
    };
  };
}
