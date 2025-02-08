{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.caddy-internal ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.1.10";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "webserver"
    ];
  };
}
