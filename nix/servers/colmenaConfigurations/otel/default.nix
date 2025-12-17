{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.otel ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "otel.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "otel"
    ];
  };
}
