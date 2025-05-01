{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.crowdsec ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "crowdsec.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "crowdsec"
    ];
  };
}
