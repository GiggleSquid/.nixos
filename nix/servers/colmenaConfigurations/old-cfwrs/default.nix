{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.old-cfwrs ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "old.cfwrs.org.uk.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "cfwrs"
    ];
  };
}
