{ inputs }:
let
  inherit (inputs) nixpkgs;
in
{
  services = {
    printing.enable = true;
    ipp-usb.enable = true;
  };
  hardware.sane = {
    enable = true;
    extraBackends = [ nixpkgs.sane-airscan ];
  };
}
