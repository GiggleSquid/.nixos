{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.cfwrs ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "cfwrs.org.uk.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "cfwrs"
    ];
  };
}
