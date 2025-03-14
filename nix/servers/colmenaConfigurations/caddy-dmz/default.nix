{ inputs, cell }:
let
  inherit (inputs) rpi;
in
{
  imports = [ cell.nixosConfigurations.caddy-dmz ];

  inherit (rpi) bee;

  deployment = rpi.deployment // {
    targetHost = "10.100.0.10";
    tags = (rpi.deployment.tags) ++ [
      "caddy"
      "webserver"
    ];
  };
}
