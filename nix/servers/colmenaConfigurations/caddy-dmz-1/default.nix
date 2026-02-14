{ inputs, cell }:
let
  inherit (inputs) rpi;
in
{
  imports = [ cell.nixosConfigurations.caddy-dmz-1 ];

  inherit (rpi) bee;

  deployment = rpi.deployment // {
    targetHost = "dmz-1.caddy.lan.gigglesquid.tech";
    tags = [
      "rpi"
      "caddy"
      "lb"
      "lb-b"
    ];
  };
}
