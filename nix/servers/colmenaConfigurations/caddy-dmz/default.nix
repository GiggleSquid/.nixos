{ inputs, cell }:
let
  inherit (inputs) rpi;
in
{
  imports = [ cell.nixosConfigurations.caddy-dmz ];

  inherit (rpi) bee;

  deployment = rpi.deployment // {
    targetHost = "dmz.caddy.lan.gigglesquid.tech";
    tags = (rpi.deployment.tags) ++ [
      "caddy"
    ];
  };
}
