{
  nixpkgs,
  self,
  ...
}: let
  inherit (self) inputs;
  bootloader = ../system/core/bootloader.nix;
  core = ../system/core;
  nvidia = ../system/nvidia;
  wayland = ../system/wayland;
  virtualisation = ../system/virtualisation;
  hmModule = inputs.home-manager.nixosModules.home-manager;

  shared = [core];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit self;
    };
    users.squid = ../home;
  };
in {
  squid-rig = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules =
      [
        {networking.hostName = "squid-rig";}
        ./squid-rig/hardware-configuration.nix
        bootloader
        nvidia
        wayland
        virtualisation
        hmModule
        {inherit home-manager;}
      ]
      ++ shared;
    specialArgs = {inherit inputs;};
  };
}
