{ inputs, cell }:
let
  common = {
    hardware = {
      opengl = {
        driSupport = true;
        driSupport32Bit = true;
      };
      enableRedistributableFirmware = true;
    };
  };
  commonNvidia = {
    hardware = {
      nvidia = {
        modesetting.enable = true;
        open = false;
        nvidiaSettings = true;
        powerManagement.enable = true;
      };
      opengl = {
        driSupport = true;
        driSupport32Bit = true;
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
