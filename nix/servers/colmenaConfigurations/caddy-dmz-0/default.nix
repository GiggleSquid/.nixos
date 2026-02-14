{ inputs, cell }:
let
  inherit (inputs) rpi;
in
{
  imports = [ cell.nixosConfigurations.caddy-dmz-0 ];

  inherit (rpi) bee;

  deployment = rpi.deployment // {
    targetHost = "dmz-0.caddy.lan.gigglesquid.tech";
    tags = [
      "rpi"
      "caddy"
      "lb"
      "lb-a"
    ];
  };
}
