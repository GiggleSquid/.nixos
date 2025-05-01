{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.caddy-internal ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "internal.caddy.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "webserver"
    ];
  };
}
