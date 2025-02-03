{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.otel ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.0.60";
    tags = (common.deployment.tags) ++ [
      "otel"
    ];
  };
}
