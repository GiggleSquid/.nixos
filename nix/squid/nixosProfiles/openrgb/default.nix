{ inputs, cells }:
let
  inherit (inputs) nixpkgs;
in
{
  services.hardware.openrgb.enable = true;
  hardware.i2c.enable = true;
  environment.systemPackages = with nixpkgs; [ i2c-tools ];
}
