{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.caddy-squid ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.0.4";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "webserver"
    ];
  };
}
