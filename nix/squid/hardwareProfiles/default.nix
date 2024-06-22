{ inputs, cell }:
let
  common = {
    hardware = {
      enableRedistributableFirmware = true;
    };
  };
  commonNvidia = {
    hardware = {
      nvidia = {
        modesetting.enable = true;
        open = false;
        nvidiaSettings = true;
        powerManagement.enable = false;
      };
      graphics = {
        extraPackages = with inputs.nixpkgs; [
          nvidia-vaapi-driver
          libvdpau-va-gl
        ];
      };
      enableRedistributableFirmware = true;
    };
  };
in
inputs.hive.findLoad {
  inherit cell;
  inputs = inputs // {
    inherit common commonNvidia;
  };
  block = ./.;
}
