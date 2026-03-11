{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.rackpeek ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "rackpeek.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "rackpeek"
    ];
  };
}
