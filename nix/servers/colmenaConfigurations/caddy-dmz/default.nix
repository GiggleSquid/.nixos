{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.caddy-dmz ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.100.0.10";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "webserver"
    ];
  };
}
